package dev.halilibrahim.torcav

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * The native half of "Torcav keeps working when the app is closed" — these
 * rules decide every alert the stabilizer raises while there is no Dart side
 * alive to check them.
 */
class StabilizerAlertRulesTest {

    private val threshold = 30.0

    /**
     * A realistic wall-clock base. The cooldown compares `nowMs` against a
     * `0L` sentinel for the first fire, so a test that starts at t=0 would
     * sit inside the cooldown window and swallow the very first alert —
     * something that cannot happen against `System.currentTimeMillis()`.
     */
    private val t0 = 1_800_000_000_000L

    private fun rules() = StabilizerAlertRules { threshold }

    /** Feeds [count] samples and returns every alert produced along the way. */
    private fun StabilizerAlertRules.feed(
        count: Int,
        jitterMs: Double,
        lost: Boolean = false,
        startMs: Long = t0,
        stepMs: Long = 1_000L,
    ): List<StabilizerAlert> {
        val out = mutableListOf<StabilizerAlert>()
        repeat(count) { i ->
            out += onSample(jitterMs, lost, startMs + i * stepMs).alerts
        }
        return out
    }

    // ── Jitter ──────────────────────────────────────────────────────────

    @Test
    fun `one bad sample does not alert`() {
        val alerts = rules().feed(1, jitterMs = 99.0)
        assertTrue(alerts.isEmpty())
    }

    @Test
    fun `two bad samples do not alert - the window is three`() {
        val alerts = rules().feed(2, jitterMs = 99.0)
        assertTrue(alerts.isEmpty())
    }

    @Test
    fun `three consecutive breaches alert once, carrying the values`() {
        val alerts = rules().feed(3, jitterMs = 99.0)

        assertEquals(1, alerts.size)
        val spike = alerts.single() as StabilizerAlert.JitterSpike
        assertEquals(99.0, spike.jitterMs, 0.001)
        assertEquals(threshold, spike.thresholdMs, 0.001)
    }

    @Test
    fun `a clean sample resets the breach run`() {
        val r = rules()
        r.feed(2, jitterMs = 99.0)
        r.feed(1, jitterMs = 5.0, startMs = t0 + 2_000)
        // Two more breaches would be three in a row only if the clean sample
        // had not reset the counter.
        val alerts = r.feed(2, jitterMs = 99.0, startMs = t0 + 3_000)
        assertTrue(alerts.isEmpty())
    }

    @Test
    fun `a sustained bad link alerts once, not on every sample`() {
        val alerts = rules().feed(60, jitterMs = 99.0)
        assertEquals(1, alerts.size)
    }

    @Test
    fun `a lost probe is loss, not jitter`() {
        // Timeouts arrive with a jitter reading that must not be trusted.
        val alerts = rules().feed(5, jitterMs = 9_999.0, lost = true)
        assertTrue(alerts.none { it is StabilizerAlert.JitterSpike })
    }

    @Test
    fun `episode re-arms only after the link genuinely settles`() {
        val r = rules()
        r.feed(3, jitterMs = 99.0) // alert 1 at t=0..2s

        // Nine clean samples: one short of the reset window.
        r.feed(9, jitterMs = 5.0, startMs = t0 + 3_000)
        assertTrue(
            "re-armed before the reset window elapsed",
            r.feed(3, jitterMs = 99.0, startMs = t0 + 12_000).isEmpty(),
        )

        // Now settle properly and get past the re-fire cooldown.
        val settled = StabilizerAlertRules.JITTER_RESET_WINDOW
        r.feed(settled, jitterMs = 5.0, startMs = t0 + 20_000)
        val alerts = r.feed(3, jitterMs = 99.0, startMs = t0 + 20_000 + 11 * 60_000L)
        assertEquals(1, alerts.size)
    }

    @Test
    fun `cooldown suppresses a second alert inside ten minutes`() {
        val r = rules()
        r.feed(3, jitterMs = 99.0)
        r.feed(StabilizerAlertRules.JITTER_RESET_WINDOW, jitterMs = 5.0, startMs = t0 + 3_000)

        // Settled, but only five minutes have passed.
        val alerts = r.feed(3, jitterMs = 99.0, startMs = t0 + 5 * 60_000L)
        assertTrue(alerts.isEmpty())
    }

    // ── Packet loss ─────────────────────────────────────────────────────

    @Test
    fun `loss below the minimum sample count is not trusted`() {
        // 100 % loss over 10 probes is not yet evidence — the rule needs 30.
        val alerts = rules().feed(10, jitterMs = 5.0, lost = true)
        assertTrue(alerts.none { it is StabilizerAlert.PacketLoss })
    }

    @Test
    fun `sustained loss past the minimum window alerts once`() {
        val alerts = rules().feed(
            StabilizerAlertRules.LOSS_MIN_SAMPLES,
            jitterMs = 5.0,
            lost = true,
        )
        val loss = alerts.filterIsInstance<StabilizerAlert.PacketLoss>()
        assertEquals(1, loss.size)
        assertEquals(100.0, loss.single().lossPct, 0.001)
    }

    @Test
    fun `loss percentage is the rolling window, not the lifetime rate`() {
        val r = rules()
        // Fill the window with losses, then flood it with clean probes.
        r.feed(StabilizerAlertRules.LOSS_WINDOW, jitterMs = 5.0, lost = true)
        val outcome = (1..StabilizerAlertRules.LOSS_WINDOW).fold(0.0) { _, i ->
            r.onSample(5.0, false, t0 + 100_000L + i * 1_000L).lossPct
        }
        assertEquals(0.0, outcome, 0.001)
    }

    @Test
    fun `a link under the alert threshold stays quiet`() {
        val r = rules()
        // 2 losses in 60 probes ≈ 3.3 %, above the clear line but below alert.
        repeat(StabilizerAlertRules.LOSS_WINDOW) { i ->
            r.onSample(5.0, lost = i < 2, nowMs = t0 + i * 1_000L)
        }
        val alerts = r.onSample(5.0, false, t0 + 61_000L).alerts
        assertTrue(alerts.none { it is StabilizerAlert.PacketLoss })
    }

    // ── Reporting ───────────────────────────────────────────────────────

    @Test
    fun `loss percentage is returned on every sample regardless of alerts`() {
        val r = rules()
        // i = 0 and 2 are losses → 2 of 4, then a fifth clean probe → 2 of 5.
        repeat(4) { i -> r.onSample(5.0, lost = i % 2 == 0, nowMs = t0 + i * 1_000L) }
        assertEquals(40.0, r.onSample(5.0, false, t0 + 5_000L).lossPct, 0.001)
    }

    @Test
    fun `threshold changes take effect on the next sample`() {
        var current = 30.0
        val r = StabilizerAlertRules { current }

        r.feed(2, jitterMs = 40.0) // breaching at 30 ms
        current = 100.0 // user relaxes the threshold mid-episode
        val alerts = r.feed(1, jitterMs = 40.0, startMs = t0 + 2_000)

        assertTrue("stale threshold was used", alerts.isEmpty())
    }

    @Test
    fun `an empty sample stream reports zero loss and no alerts`() {
        val outcome = rules().onSample(5.0, false, t0)
        assertEquals(0.0, outcome.lossPct, 0.001)
        assertTrue(outcome.alerts.isEmpty())
        assertNull(outcome.alerts.firstOrNull())
    }
}
