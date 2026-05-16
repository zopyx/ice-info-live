import SwiftUI
import MapKit

struct TrainMapView: View {
    let status: TrainStatus

    @State private var camera: MapCameraPosition = .automatic

    var body: some View {
        if status.latitude == 0 && status.longitude == 0 {
            Spacer()
            Text("Keine Positionsdaten")
                .foregroundStyle(.secondary)
            Spacer()
                .background(Color(.systemBackground))
        } else {
            Map(position: $camera) {
                Annotation(
                    "\(status.trainType) \(status.trainNumber)",
                    coordinate: CLLocationCoordinate2D(
                        latitude: status.latitude,
                        longitude: status.longitude
                    )
                ) {
                    Image(systemName: "tram.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color(red: 0.925, green: 0, blue: 0.086))
                        .clipShape(Circle())
                }
            }
            .onAppear {
                camera = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: status.latitude,
                        longitude: status.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                ))
            }
            .onChange(of: status.latitude) { _, _ in
                withAnimation {
                    camera = .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: status.latitude,
                            longitude: status.longitude
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    ))
                }
            }
        }
    }
}
