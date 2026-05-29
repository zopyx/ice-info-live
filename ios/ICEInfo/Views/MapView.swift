import SwiftUI
import MapKit

struct TrainMapView: View {
    let status: TrainStatus

    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        let coordinate = CLLocationCoordinate2D(
            latitude: status.latitude,
            longitude: status.longitude
        )

        let hasValidPosition = status.latitude != 0 || status.longitude != 0

        Map(position: $position) {
            if hasValidPosition {
                Marker("ICE \(status.trainNumber)", coordinate: coordinate)
                    .tint(Color(red: 0.925, green: 0, blue: 0.086))
            }
        }
        .onChange(of: status.latitude) { _, _ in
            if hasValidPosition {
                withAnimation(.easeInOut(duration: 2)) {
                    position = .region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    ))
                }
            }
        }
        .overlay {
            if !hasValidPosition {
                ContentUnavailableView(
                    "Keine Position",
                    systemImage: "location.slash",
                    description: Text("Die Zugposition ist nicht verf\u{00FC}gbar.")
                )
            }
        }
    }
}
