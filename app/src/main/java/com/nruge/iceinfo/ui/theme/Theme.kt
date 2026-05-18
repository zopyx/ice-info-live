package com.nruge.iceinfo.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.ui.platform.LocalContext

val LocalDarkTheme = compositionLocalOf { false }

@Composable
fun ICEInfoTheme(
    darkTheme: Boolean = false,
    content: @Composable () -> Unit
) {
    val ctx = LocalContext.current
    val colorScheme = if (darkTheme) dynamicDarkColorScheme(ctx) else dynamicLightColorScheme(ctx)

    CompositionLocalProvider(LocalDarkTheme provides darkTheme) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}
