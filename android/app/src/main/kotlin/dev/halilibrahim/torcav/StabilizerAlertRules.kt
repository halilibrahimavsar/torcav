package dev.halilibrahim.torcav

/** A rule outcome the engine should surface to the user. */
sealed interface StabilizerAlert {
    data class JitterSpike(val jitterMs: Double, val thresholdMs: Double) : StabilizerAlert

    data class PacketLoss(val lossPct: Double) : StabilizerAlert
}

/**
 * Jitter and packet-loss episode rules for the ping stabilizer.
 *
 * Deliberately pure: no Android types, no notifications, no wall clock of its
 * own — `nowMs` is passed in. That is what makes these rules testable on the
 * JVM without Robolectric, which matters because they are the native half of
 * the product promise that the app keeps working when it is closed.
 *
 * The engine owns delivery; this class owns *whether* something is worth
 * delivering. Both episode rules are hysteretic on purpose: a single bad
 * sample must not alert, and a recovered link must not re-alert until it has
 * genuinely settled.
 */
class StabilizerAlertRules(
    /**
     * Read per sample rather than captured once — the Dart side can push a new
     * threshold through `StabilizerConfig` while the tunnel is running.
     */
    private val jitterThresholdMs: () -> Double,
) {
    companion object {
        /** Consecutive over-threshold samples before a jitter alert fires. */
        const val JITTER_BREACH_WINDOW = 3

        /** Clean samples required before a new jitter episode may re-alert. */
        const val JITTER_RESET_WINDOW = 10

        /** Rolling probe-outcome window for loss percentage (≈1 min @ 1 Hz). */
        const val LOSS_WINDOW = 60

        /** Minimum filled window before the loss rule is trusted. */
        const val LOSS_MIN_SAMPLES = 30
        const val LOSS_ALERT_PCT = 5.0
        const val LOSS_CLEAR_PCT = 2.0

        /** Floor between two alerts of the same kind. */
        const val REFIRE_COOLDOWN_MS = 10 * 60_000L
    }

    /** Result of feeding one 1 Hz probe outcome through the rules. */
    data class Outcome(val lossPct: Double, val alerts: List<StabilizerAlert>)

    // ── Jitter episode state ────────────────────────────────────────────
    private var consecutiveBreaches = 0
    private var cleanSamples = 0
    private var jitterEpisodeActive = false

    // ── Loss window (true = probe timed out) ────────────────────────────
    private val lossWindow = ArrayDeque<Boolean>()
    private var lossEpisodeActive = false

    // ── Cooldown, keyed by alert kind ───────────────────────────────────
    private val lastFiredAtMs = HashMap<String, Long>()

    /**
     * Feed one probe outcome. Returns the current rolling loss percentage
     * (which the service emits to Flutter regardless) plus any alerts that
     * became due on this sample.
     */
    fun onSample(jitterMs: Double, lost: Boolean, nowMs: Long): Outcome {
        lossWindow.addLast(lost)
        while (lossWindow.size > LOSS_WINDOW) lossWindow.removeFirst()
        val lossPct =
            if (lossWindow.isEmpty()) 0.0
            else lossWindow.count { it } * 100.0 / lossWindow.size

        val alerts = mutableListOf<StabilizerAlert>()
        evaluateJitter(jitterMs, lost, nowMs)?.let { alerts.add(it) }
        evaluateLoss(lossPct, nowMs)?.let { alerts.add(it) }
        return Outcome(lossPct, alerts)
    }

    private fun evaluateJitter(
        jitterMs: Double,
        lost: Boolean,
        nowMs: Long,
    ): StabilizerAlert? {
        if (lost) return null // timeouts are loss, not jitter

        val threshold = jitterThresholdMs()
        if (jitterMs > threshold) {
            consecutiveBreaches++
            cleanSamples = 0
        } else {
            consecutiveBreaches = 0
            cleanSamples++
            if (cleanSamples >= JITTER_RESET_WINDOW) jitterEpisodeActive = false
        }

        if (consecutiveBreaches >= JITTER_BREACH_WINDOW && !jitterEpisodeActive) {
            // The episode latches even when the cooldown swallows the alert,
            // so a still-bad link does not re-arm the moment the cooldown
            // expires — it has to recover first.
            jitterEpisodeActive = true
            if (cooldownOk("jitter", nowMs)) {
                return StabilizerAlert.JitterSpike(jitterMs, threshold)
            }
        }
        return null
    }

    private fun evaluateLoss(lossPct: Double, nowMs: Long): StabilizerAlert? {
        if (lossPct < LOSS_CLEAR_PCT) lossEpisodeActive = false
        // Below the minimum sample count the percentage is noise: 1 timeout in
        // the first 4 probes is 25 %, which is not evidence of anything.
        if (lossWindow.size < LOSS_MIN_SAMPLES) return null

        if (lossPct >= LOSS_ALERT_PCT && !lossEpisodeActive) {
            lossEpisodeActive = true
            if (cooldownOk("loss", nowMs)) {
                return StabilizerAlert.PacketLoss(lossPct)
            }
        }
        return null
    }

    private fun cooldownOk(kind: String, nowMs: Long): Boolean {
        val last = lastFiredAtMs[kind] ?: 0L
        if (nowMs - last < REFIRE_COOLDOWN_MS) return false
        lastFiredAtMs[kind] = nowMs
        return true
    }
}
