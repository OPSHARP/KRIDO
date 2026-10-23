package com.krido.kidsapp

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.decorView.post {
            enableHighRefreshRate()
        }
    }

    /**
     * Dynamically sets preferred display mode to the highest supported refresh rate
     * (90Hz / 120Hz / 144Hz) for maximum fluid animation and low latency touch response.
     */
    private fun enableHighRefreshRate() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    display
                } else {
                    @Suppress("DEPRECATION")
                    windowManager.defaultDisplay
                }
                display?.supportedModes?.maxByOrNull { it.refreshRate }?.let { maxMode ->
                    val params = window.attributes
                    if (params.preferredDisplayModeId != maxMode.modeId) {
                        params.preferredDisplayModeId = maxMode.modeId
                        window.attributes = params
                    }
                }
            }
        } catch (_: Exception) {
            // Gracefully ignore display mode adjustment errors on OEM forks or emulators
        }
    }
}
