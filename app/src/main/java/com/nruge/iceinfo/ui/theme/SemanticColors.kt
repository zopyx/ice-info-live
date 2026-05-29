package com.nruge.iceinfo.ui.theme

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.graphics.Color

@Composable fun successContainer(): Color =
    if (LocalDarkTheme.current) SuccessContainerDark else SuccessContainerLight

@Composable fun onSuccessContainer(): Color =
    if (LocalDarkTheme.current) OnSuccessContainerDark else OnSuccessContainerLight

@Composable fun warningContainer(): Color =
    if (LocalDarkTheme.current) WarningContainerDark else WarningContainerLight

@Composable fun onWarningContainer(): Color =
    if (LocalDarkTheme.current) OnWarningContainerDark else OnWarningContainerLight

@Composable
fun rainbowColor(): Color {
    val isDark = LocalDarkTheme.current
    val transition = rememberInfiniteTransition(label = "rainbow")
    val hue by transition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 2000, easing = LinearEasing)
        ),
        label = "hue"
    )
    val saturation = if (isDark) 0.65f else 0.80f
    val value = if (isDark) 0.95f else 0.65f
    return Color(android.graphics.Color.HSVToColor(floatArrayOf(hue, saturation, value)))
}
