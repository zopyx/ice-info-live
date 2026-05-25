package com.nruge.iceinfo.util

import android.content.Context
import android.content.Intent
import androidx.core.content.FileProvider
import com.nruge.iceinfo.model.SavedJourney
import java.io.File
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter

object GpxExporter {

    private val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
    private val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")
    private val gpxTimestampFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'")

    fun shareGpx(context: Context, journey: SavedJourney) {
        val gpxContent = generateGpx(journey)
        val fileName = "ICE_${journey.trainNumber}_${journey.date.replace(".", "-")}.gpx"

        val dir = File(context.cacheDir, "gpx").also { it.mkdirs() }
        val file = File(dir, fileName)
        file.writeText(gpxContent)

        val uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            file
        )

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "application/gpx+xml"
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(Intent.EXTRA_SUBJECT, "${journey.trainType} ${journey.trainNumber} · ${journey.date}")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        context.startActivity(Intent.createChooser(intent, "GPX-Datei teilen"))
    }

    fun generateGpx(journey: SavedJourney): String {
        val departureDateTime = runCatching {
            val date = LocalDate.parse(journey.date, dateFormatter)
            val time = LocalTime.parse(journey.departureTime, timeFormatter)
            LocalDateTime.of(date, time)
        }.getOrNull()

        val sb = StringBuilder()
        sb.appendLine("""<?xml version="1.0" encoding="UTF-8"?>""")
        sb.appendLine(
            """<gpx version="1.1" creator="ICE Info" """ +
            """xmlns="http://www.topografix.com/GPX/1/1" """ +
            """xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" """ +
            """xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">"""
        )
        sb.appendLine("  <metadata>")
        sb.appendLine("    <name>${journey.trainType} ${journey.trainNumber} · ${journey.originStation} → ${journey.destinationStation}</name>")
        if (departureDateTime != null) {
            sb.appendLine("    <time>${departureDateTime.format(gpxTimestampFormatter)}</time>")
        }
        sb.appendLine("  </metadata>")
        sb.appendLine("  <trk>")
        sb.appendLine("    <name>${journey.trainType} ${journey.trainNumber} · ${journey.date}</name>")
        sb.appendLine("    <trkseg>")

        for (point in journey.trackPoints) {
            val timestamp = departureDateTime
                ?.plusSeconds(point.secondsFromStart.toLong())
                ?.format(gpxTimestampFormatter)

            sb.appendLine("""      <trkpt lat="${point.lat}" lon="${point.lon}">""")
            if (timestamp != null) {
                sb.appendLine("        <time>$timestamp</time>")
            }
            sb.appendLine("        <extensions><speed>${point.speedKmh}</speed></extensions>")
            sb.appendLine("      </trkpt>")
        }

        sb.appendLine("    </trkseg>")
        sb.appendLine("  </trk>")
        sb.append("</gpx>")
        return sb.toString()
    }
}
