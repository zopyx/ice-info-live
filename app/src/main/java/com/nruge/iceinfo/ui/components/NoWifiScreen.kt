package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material.icons.filled.WifiTetheringError
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import android.content.Intent
import android.provider.Settings
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.ui.theme.ICEInfoTheme
import com.nruge.iceinfo.util.getIceDrawable

@Composable
fun NoWifiScreen(
    modifier: Modifier = Modifier,
    status: TrainStatus? = null,
    isWIFIonICE: Boolean = false,
    onRetry: () -> Unit = {},
    onMockMode: () -> Unit = {}
) {
    val context = LocalContext.current
    Column(
        modifier = modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        HeroIllustration(tzn = status?.tzn ?: "")

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = stringResource(R.string.welcome_title),
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 24.dp)
        )

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = stringResource(R.string.welcome_subtitle),
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 32.dp)
        )

        Spacer(modifier = Modifier.height(32.dp))

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            WelcomeActionCard(
                icon = if (isWIFIonICE) Icons.Default.WifiTetheringError else Icons.Default.Wifi,
                title = stringResource(
                    if (isWIFIonICE) R.string.no_wifi_api_hint
                    else R.string.welcome_connect_title
                ),
                description = stringResource(
                    if (isWIFIonICE) R.string.no_wifi_text
                    else R.string.welcome_connect_desc
                ),
                containerColor = MaterialTheme.colorScheme.primaryContainer,
                contentColor = MaterialTheme.colorScheme.onPrimaryContainer,
                onClick = {
                    context.startActivity(
                        Intent(Settings.ACTION_WIFI_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )
                    onRetry()
                }
            )

            WelcomeActionCard(
                icon = Icons.Default.PlayArrow,
                title = stringResource(R.string.demo_mode),
                description = stringResource(R.string.welcome_demo_desc),
                containerColor = MaterialTheme.colorScheme.secondaryContainer,
                contentColor = MaterialTheme.colorScheme.onSecondaryContainer,
                onClick = onMockMode
            )
        }

        Spacer(modifier = Modifier.height(32.dp))
    }
}

@Composable
private fun HeroIllustration(tzn: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(220.dp)
            .graphicsLayer { clip = false },
        contentAlignment = Alignment.BottomCenter
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(80.dp)
                .align(Alignment.BottomStart)
                .wrapContentWidth(unbounded = true, align = Alignment.Start)
                .offset(x = (-20).dp, y = (-30).dp)
                .zIndex(1f)
        ) {
            repeat(3) {
                Image(
                    painter = painterResource(id = R.drawable.traintracks),
                    contentDescription = null,
                    contentScale = ContentScale.FillHeight,
                    modifier = Modifier
                        .height(100.dp)
                        .wrapContentWidth(unbounded = true)
                )
            }
        }
        Image(
            painter = painterResource(id = getIceDrawable(tzn)),
            contentDescription = null,
            contentScale = ContentScale.Fit,
            modifier = Modifier
                .height(71.dp)
                .wrapContentWidth(unbounded = true, align = Alignment.Start)
                .align(Alignment.BottomStart)
                .offset(x = (-190).dp, y = (-33).dp)
                .zIndex(2f)
                .graphicsLayer { clip = false }
        )
    }
}

@Composable
private fun WelcomeActionCard(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    title: String,
    description: String,
    containerColor: androidx.compose.ui.graphics.Color,
    contentColor: androidx.compose.ui.graphics.Color,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.extraLarge,
        color = containerColor,
        contentColor = contentColor
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 20.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Surface(
                shape = MaterialTheme.shapes.medium,
                color = contentColor.copy(alpha = 0.12f),
                modifier = Modifier.size(48.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = icon,
                        contentDescription = null,
                        tint = contentColor
                    )
                }
            }
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = description,
                    style = MaterialTheme.typography.bodySmall,
                    color = contentColor.copy(alpha = 0.75f)
                )
            }
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                contentDescription = null,
                tint = contentColor.copy(alpha = 0.7f)
            )
        }
    }
}

@Preview(showBackground = true, heightDp = 800)
@Composable
fun NoWifiScreenPreview() {
    ICEInfoTheme {
        NoWifiScreen()
    }
}

@Preview(showBackground = true, heightDp = 800)
@Composable
fun NoWifiScreenApiDownPreview() {
    ICEInfoTheme {
        NoWifiScreen(isWIFIonICE = true)
    }
}
