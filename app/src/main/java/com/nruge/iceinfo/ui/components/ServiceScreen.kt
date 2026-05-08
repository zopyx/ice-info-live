package com.nruge.iceinfo.ui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.nruge.iceinfo.R
import com.nruge.iceinfo.model.TrainStatus

@Composable
fun ServiceScreen(status: TrainStatus) {
    Box(
        modifier = Modifier.fillMaxSize().padding(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 96.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = stringResource(R.string.service_wip),
            style = MaterialTheme.typography.headlineMedium
        )
    }
}
