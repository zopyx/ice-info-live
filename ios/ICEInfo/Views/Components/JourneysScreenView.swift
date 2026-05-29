import SwiftUI

struct JourneysScreenView: View {
    let journeys: [SavedJourney]
    let onDeleteJourney: (String) -> Void
    let isConnected: Bool
    let isRecording: Bool
    let liveRecording: LiveRecordingState?
    let onStartRecording: () -> Void
    var onShareGpx: ((SavedJourney) -> Void)? = nil

    @State private var deleteConfirmId: String? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if journeys.isEmpty && !isRecording {
                emptyState
            } else {
                journeyList
            }

            if isConnected && !isRecording {
                recordButton
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Keine Reisen aufgezeichnet")
                .font(.headline)
            Text("Starte eine Aufzeichnung, um deine Reise zu speichern.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var journeyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isRecording, let recording = liveRecording {
                    LiveJourneyCard(recording: recording)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }

                ForEach(journeys) { journey in
                    JourneyCard(
                        journey: journey,
                        onDelete: { deleteConfirmId = journey.id },
                        onShare: onShareGpx
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, journeys.first?.id == journey.id && !isRecording ? 16 : 0)
                }
                .padding(.bottom, 80)
            }
        }
        .confirmationDialog(
            "Reise l\u{00F6}schen?",
            isPresented: Binding(
                get: { deleteConfirmId != nil },
                set: { if !$0 { deleteConfirmId = nil } }
            ),
            presenting: deleteConfirmId
        ) { id in
            Button("L\u{00F6}schen", role: .destructive) {
                onDeleteJourney(id)
                deleteConfirmId = nil
            }
            Button("Abbrechen", role: .cancel) {
                deleteConfirmId = nil
            }
        } message: { _ in
            Text("Diese Reise dauerhaft l\u{00F6}schen?")
        }
    }

    private var recordButton: some View {
        Button(action: onStartRecording) {
            Label("Reise aufzeichnen", systemImage: "record.circle")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(red: 0.925, green: 0, blue: 0.086))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .padding(16)
    }
}

private struct LiveJourneyCard: View {
    let recording: LiveRecordingState

    var body: some View {
        AppCard {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.925, green: 0, blue: 0.086))
                        .frame(width: 36, height: 36)
                    Image(systemName: "record.circle")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(recording.trainType) \(recording.trainNumber)")
                        .font(.subheadline.weight(.bold))
                    Text("\(recording.originStation) \u{2192} \(recording.destinationStation)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                liveBadge
            }
            .padding(12)
        }
    }

    private var liveBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(red: 0.925, green: 0, blue: 0.086))
                .frame(width: 6, height: 6)
            Text("LIVE")
                .font(.caption2.bold())
                .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(red: 0.925, green: 0, blue: 0.086).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

private struct JourneyCard: View {
    let journey: SavedJourney
    let onDelete: () -> Void
    let onShare: ((SavedJourney) -> Void)?

    var body: some View {
        AppCard {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    TrainTypeBadge(type: journey.trainType)
                    Text(journey.trainNumber)
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Text(journey.date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)

                Divider()

                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(journey.departureTime)
                                .font(.title3.weight(.bold))
                            Text(journey.originStation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        VStack(spacing: 2) {
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            if journey.delayMinutes > 0 {
                                DelayBadge(delayMinutes: journey.delayMinutes)
                                    .scaleEffect(0.8)
                            }
                        }

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(journey.arrivalTime)
                                .font(.title3.weight(.bold))
                            Text(journey.destinationStation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Divider()

                    HStack(spacing: 0) {
                        statItem("\(journey.distanceKm) km", "Strecke")
                        Spacer()
                        statItem("\(journey.avgSpeedKmh) km/h", "\u{00D8} Geschw.")
                        Spacer()
                        statItem("\(journey.topSpeedKmh) km/h", "Max")
                    }
                }
                .padding(16)

                Divider()

                HStack(spacing: 0) {
                    if journey.recordedGps {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text("GPS")
                                .font(.caption2)
                        }
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    Spacer()

                    if journey.recordedGps, let share = onShare {
                        Button {
                            share(journey)
                        } label: {
                            Label("GPX", systemImage: "square.and.arrow.up")
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
                        }
                        .padding(.trailing, 12)
                    }

                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
    }

    private func statItem(_ value: String, _ label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.subheadline.weight(.semibold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    JourneysScreenView(
        journeys: sampleJourneys,
        onDeleteJourney: { _ in },
        isConnected: true,
        isRecording: true,
        liveRecording: LiveRecordingState(
            trainType: "ICE", trainNumber: "212",
            originStation: "Hamburg-Altona", destinationStation: "M\u{00FC}nchen Hbf",
            date: "12.05.2025", departureTime: "08:13",
            startMs: 1747030000000, currentSpeedKmh: 114, topSpeedKmh: 280,
            sampleCount: 450, trackPointCount: 2800, recordGps: true
        ),
        onStartRecording: {}
    )
}
