package dev.halilibrahim.torcav

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.telephony.CellInfo
import android.telephony.CellInfoCdma
import android.telephony.CellInfoGsm
import android.telephony.CellInfoLte
import android.telephony.CellInfoNr
import android.telephony.CellInfoTdscdma
import android.telephony.CellInfoWcdma
import android.telephony.CellSignalStrength
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Read-only cellular visibility for the Wi-Fi vs mobile comparison card.
 *
 * Deliberately built WITHOUT `READ_PHONE_STATE` (the manifest strips that
 * permission to keep the Play Data-Safety declaration lean):
 *  - operator name via [TelephonyManager.getNetworkOperatorName] — no
 *    permission required;
 *  - generation + signal strength from the *registered* cells in
 *    [TelephonyManager.getAllCellInfo] — gated on ACCESS_FINE_LOCATION,
 *    which the app already requests for Wi-Fi scanning;
 *  - "mobile data in use" + OS bandwidth estimate from
 *    [ConnectivityManager.getNetworkCapabilities] — no permission required.
 *
 * Everything is a one-shot snapshot; the Dart side polls on demand. No
 * cell identity (CID/TAC) ever crosses the channel — signal + generation
 * only, in keeping with the privacy-first posture.
 */
class CellularChannelHandler(private val context: Context) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "torcav/cellular"

        /** dBm values Android reports when the modem has no reading. */
        private const val UNAVAILABLE_DBM = Int.MAX_VALUE
    }

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> {
                try {
                    result.success(readStatus())
                } catch (e: Exception) {
                    result.error("CELLULAR_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun readStatus(): Map<String, Any?> {
        val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        val operator = tm.networkOperatorName?.takeIf { it.isNotBlank() }

        var mobileDataActive = false
        var downKbps: Int? = null
        var upKbps: Int? = null
        try {
            val caps = cm.getNetworkCapabilities(cm.activeNetwork)
            if (caps != null && caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                mobileDataActive = true
                downKbps = caps.linkDownstreamBandwidthKbps.takeIf { it > 0 }
                upKbps = caps.linkUpstreamBandwidthKbps.takeIf { it > 0 }
            }
        } catch (_: Exception) {
            // Connectivity snapshot is best-effort.
        }

        val hasLocation = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED

        var generation: String? = null
        var dbm: Int? = null
        var level: Int? = null
        if (hasLocation) {
            val best = pickRegisteredCell(tm)
            if (best != null) {
                generation = generationOf(best)
                signalOf(best)?.let { signal ->
                    dbm = signal.dbm.takeIf { it != UNAVAILABLE_DBM }
                    // 0..4 per Android's own bucket definition.
                    level = signal.level
                }
            }
        }

        return mapOf(
            "operator" to operator,
            "generation" to generation,
            "dbm" to dbm,
            "level" to level,
            "mobileDataActive" to mobileDataActive,
            "downKbps" to downKbps,
            "upKbps" to upKbps,
            "permissionMissing" to !hasLocation,
        )
    }

    /**
     * The serving cell, preferring the newest radio when several are
     * registered (5G NSA setups report both an LTE anchor and an NR cell).
     */
    @SuppressLint("MissingPermission")
    private fun pickRegisteredCell(tm: TelephonyManager): CellInfo? {
        val cells: List<CellInfo> = try {
            tm.allCellInfo ?: emptyList()
        } catch (_: SecurityException) {
            emptyList()
        } catch (_: Exception) {
            emptyList()
        }
        return cells
            .filter { it.isRegistered }
            .minByOrNull { rankOf(it) }
    }

    /** Lower rank = newer radio = preferred for display. */
    private fun rankOf(info: CellInfo): Int = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info is CellInfoNr -> 0
        info is CellInfoLte -> 1
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info is CellInfoTdscdma -> 2
        info is CellInfoWcdma -> 2
        info is CellInfoCdma -> 3
        info is CellInfoGsm -> 4
        else -> 5
    }

    private fun generationOf(info: CellInfo): String? = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info is CellInfoNr -> "5G"
        info is CellInfoLte -> "4G"
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info is CellInfoTdscdma -> "3G"
        info is CellInfoWcdma -> "3G"
        info is CellInfoCdma -> "3G"
        info is CellInfoGsm -> "2G"
        else -> null
    }

    private fun signalOf(info: CellInfo): CellSignalStrength? = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info is CellInfoNr ->
            info.cellSignalStrength
        info is CellInfoLte -> info.cellSignalStrength
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info is CellInfoTdscdma ->
            info.cellSignalStrength
        info is CellInfoWcdma -> info.cellSignalStrength
        info is CellInfoCdma -> info.cellSignalStrength
        info is CellInfoGsm -> info.cellSignalStrength
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> info.cellSignalStrength
        else -> null
    }
}
