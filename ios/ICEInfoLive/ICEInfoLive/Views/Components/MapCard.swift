import SwiftUI
import MapKit

struct MapCard: View {
    let coordinate: Coordinate
    let trainName: String

    @State private var position: MapCameraPosition

    init(coordinate: Coordinate, trainName: String) {
        self.coordinate = coordinate
        self.trainName = trainName
        let clCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(
            center: clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        _position = State(initialValue: .region(region))
    }

    var body: some View {
        Map(position: $position) {
            Annotation(trainName, coordinate: clCoordinate) {
                Image(systemName: "train.side.front.car")
                    .font(.title2)
                    .foregroundColor(.dbRed)
                    .padding(8)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .mapStyle(.standard)
        .cornerRadius(20)
    }

    private var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
