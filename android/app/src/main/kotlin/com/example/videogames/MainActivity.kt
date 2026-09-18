package com.example.videogames

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableHighRefreshRate()
    }

    override fun onResume() {
        super.onResume()
        enableHighRefreshRate()
    }

    private fun enableHighRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display
            } else {
                @Suppress("DEPRECATION")
                windowManager.defaultDisplay
            }

            display?.supportedModes?.let { modes ->
                var maxRate = 60.0f
                var targetId = 0
                for (mode in modes) {
                    if (mode.refreshRate > maxRate) {
                        maxRate = mode.refreshRate
                        targetId = mode.modeId
                    }
                }

                val window = window
                val layoutParams = window.attributes
                if (targetId != 0) {
                    layoutParams.preferredDisplayModeId = targetId
                    window.attributes = layoutParams
                }
            }
        }
    }
}
