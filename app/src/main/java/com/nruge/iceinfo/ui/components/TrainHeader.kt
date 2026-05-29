package com.nruge.iceinfo.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandHorizontally
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkHorizontally
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.compose.ui.tooling.preview.Preview
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.TrainStatus
import com.nruge.iceinfo.sampleTrainStatus
import com.nruge.iceinfo.ui.theme.ICEInfoTheme
import com.nruge.iceinfo.util.IceUtils

@Composable
fun TrainHeader(status: TrainStatus, reducedMotion: Boolean = false) {
    val density = LocalDensity.current
    var trackWidthPx by remember { mutableStateOf(300f) }
    var trackOffset by remember { mutableStateOf(0f) }
    val currentStatus by rememberUpdatedState(status)

    LaunchedEffect(reducedMotion) {
        if (reducedMotion) {
            trackOffset = 0f
            return@LaunchedEffect
        }
        var lastTime = withFrameNanos { it }
        while (true) {
            withFrameNanos { time ->
                val dt = (time - lastTime) / 1_000_000_000f
                lastTime = time

                val speed = currentStatus.speed
                if (speed > 0) {
                    val trackWidthDp = trackWidthPx / density.density
                    val velocity = (trackWidthDp * speed) / 300f
                    trackOffset -= dt * velocity

                    if (trackOffset <= -trackWidthDp) {
                        trackOffset += trackWidthDp
                    }
                }
            }
        }
    }
    Spacer(modifier = Modifier.height(5.dp))
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(140.dp)
            .graphicsLayer { clip = false }
    )
    {
        Row(
            modifier = Modifier
                .height(50.dp)
                .wrapContentWidth(unbounded = true, align = Alignment.Start)
                .align(Alignment.CenterStart)
                .offset { IntOffset((trackOffset - 17f).dp.roundToPx(), (-45).dp.roundToPx()) }
                .zIndex(1f)
                .onGloballyPositioned { coords ->
                    trackWidthPx = coords.size.width / 5f
                }
        ) {
            repeat(5) {
                Image(
                    painter = painterResource(id = R.drawable.traintracks),
                    contentDescription = null,
                    contentScale = ContentScale.FillHeight,
                    modifier = Modifier
                        .height(50.dp)
                        .wrapContentWidth(unbounded = true)
                )
            }
        }

        Image(
            painter = painterResource(id = IceUtils.getIceDrawable(status.tzn)),
            contentDescription = null,
            alignment = Alignment.CenterStart,
            contentScale = ContentScale.FillHeight,
            modifier = Modifier
                .height(44.dp)
                .wrapContentWidth(unbounded = true, align = Alignment.Start)
                .align(Alignment.CenterStart)
                .offset(x = (-150).dp, y = (-44).dp)
                .zIndex(2f)
                .graphicsLayer { clip = false }
        )

        AppCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 50.dp),
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "${status.trainType} ${status.trainNumber}",
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        fontStyle = FontStyle.Italic,
                        color = MaterialTheme.colorScheme.tertiary
                    )

                    val seriesLabel = IceUtils.getIceClassFromSeries(status.series, status.tzn)
                    val vmax = IceUtils.getIceVmax(status.series)
                    val specialName = IceUtils.getSpecialName(status.tzn)
                    val tzName = IceUtils.getTzName(status.tzn)
                    val nameText = when {
                        specialName != null && tzName != null -> "${tzName.name} · ${specialName.name}"
                        specialName != null -> specialName.name
                        tzName != null -> tzName.name
                        else -> ""
                    }
                    val hasDetails = vmax != null || nameText.isNotEmpty()
                    var expanded by remember { mutableStateOf(false) }

                    if (seriesLabel.isNotEmpty()) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.clickable(enabled = hasDetails) { expanded = !expanded }
                        ) {
                            Text(
                                text = seriesLabel,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.7f)
                            )
                            if (hasDetails) {
                                Text(
                                    text = "›",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.7f),
                                    modifier = Modifier
                                        .padding(start = 3.dp)
                                        .rotate(if (expanded) 180f else 0f)
                                )
                            }
                            AnimatedVisibility(
                                visible = expanded,
                                enter = expandHorizontally() + fadeIn(),
                                exit = shrinkHorizontally() + fadeOut()
                            ) {
                                val details = buildList {
                                    if (nameText.isNotEmpty()) add(nameText)
                                    if (vmax != null) add("Vmax $vmax km/h")
                                }.joinToString(" · ")
                                Text(
                                    text = "  $details",
                                    style = MaterialTheme.typography.bodySmall,
                                    fontStyle = FontStyle.Italic,
                                    color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.55f)
                                )
                            }
                        }
                    }
                }
                Text(
                    text = "${status.speed} km/h",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Black,
                    color = MaterialTheme.colorScheme.tertiary
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun TrainHeaderPreview() {
    ICEInfoTheme {
        TrainHeader(status = sampleTrainStatus)
    }
}
