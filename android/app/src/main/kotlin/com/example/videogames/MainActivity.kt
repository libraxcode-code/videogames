package com.example.videogames

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Request 120 Hz / Highest display refresh rate mode
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val window = window
            val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display
            } else {
                @Suppress("DEPRECATION")
                windowManager.defaultDisplay
            }

            display?.supportedModes?.let { modes ->
                var maxRefreshRate = 60.0f
                var targetModeId = 0
                for (mode in modes) {
                    if (mode.refreshRate > maxRefreshRate) {
                        maxRefreshRate = mode.refreshRate
                        targetModeId = mode.modeId
                    }
                }
                if (targetModeId != 0) {
                    val params = window.attributes
                    params.preferredDisplayModeId = targetModeId
                    window.attributes = params
                }
            }
        }
    }
}
