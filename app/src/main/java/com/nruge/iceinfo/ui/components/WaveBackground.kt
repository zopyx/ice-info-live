package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.unit.dp
import kotlin.math.sin

private class WavePathCache {
    var size: Size = Size.Zero
    var paths: List<Path> = emptyList()
}

@Composable
fun WaveBackground(modifier: Modifier = Modifier) {
    val secondaryColor = MaterialTheme.colorScheme.secondary
    val tertiaryColor = MaterialTheme.colorScheme.tertiary
    val primaryColor = MaterialTheme.colorScheme.primary
    val cache = remember { WavePathCache() }

    Canvas(modifier = modifier.fillMaxSize().blur(radiusX = 20.dp, radiusY = 20.dp)) {
        // Recompute paths only when screen size changes (first draw or rotation)
        if (size != cache.size) {
            cache.size = size
            cache.paths = buildPaths(size)
        }
        val (pathTop, path1, path2, pathBottom) = cache.paths

        drawPath(pathTop,    color = tertiaryColor.copy(alpha = 0.12f))
        drawPath(path1,      color = secondaryColor.copy(alpha = 0.14f))
        drawPath(path2,      color = tertiaryColor.copy(alpha = 0.16f))
        drawPath(pathBottom, color = primaryColor.copy(alpha = 0.11f))
    }
}

private fun buildPaths(size: Size): List<Path> {
    val w = size.width
    val h = size.height
    val steps = 120

    fun organicY(t: Double, baseY: Float, components: List<Triple<Double, Double, Double>>): Float {
        val offset = components.sumOf { (freq, amp, phase) -> sin(t * freq + phase) * amp }
        return baseY + offset.toFloat()
    }

    fun waveRibbon(centerY: Float, thickness: Float, components: List<Triple<Double, Double, Double>>): Path {
        return Path().apply {
            moveTo(0f, organicY(0.0, centerY - thickness / 2, components))
            for (i in 1..steps) {
                val t = i.toDouble() / steps
                lineTo(w * i / steps, organicY(t, centerY - thickness / 2, components))
            }
            for (i in steps downTo 0) {
                val t = i.toDouble() / steps
                lineTo(w * i / steps, organicY(t, centerY + thickness / 2, components))
            }
            close()
        }
    }

    val pathTop = waveRibbon(
        centerY = h * 0.23f, thickness = h * 0.07f,
        components = listOf(
            Triple(1.1 * Math.PI, h * 0.045, 2.3),
            Triple(3.2 * Math.PI, h * 0.018, 0.9),
            Triple(6.7 * Math.PI, h * 0.007, 4.1)
        )
    )
    val path1 = waveRibbon(
        centerY = h * 0.43f, thickness = h * 0.2f,
        components = listOf(
            Triple(0.85 * Math.PI, h * 0.075, 0.0),
            Triple(2.3  * Math.PI, h * 0.022, 1.2),
            Triple(5.1  * Math.PI, h * 0.008, 2.7)
        )
    )
    val path2 = waveRibbon(
        centerY = h * 0.57f, thickness = h * 0.15f,
        components = listOf(
            Triple(0.6  * Math.PI, h * 0.065, 1.9),
            Triple(1.85 * Math.PI, h * 0.028, 0.5),
            Triple(4.4  * Math.PI, h * 0.009, 3.8)
        )
    )
    val pathBottom = waveRibbon(
        centerY = h * 0.87f, thickness = h * 0.09f,
        components = listOf(
            Triple(0.7  * Math.PI, h * 0.055, 3.5),
            Triple(2.05 * Math.PI, h * 0.024, 1.6),
            Triple(5.3  * Math.PI, h * 0.009, 0.3)
        )
    )

    return listOf(pathTop, path1, path2, pathBottom)
}
