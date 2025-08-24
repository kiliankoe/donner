import MapKit
import SwiftUI

struct StrikeRowMapBackground: View {
  let strikeLocation: CLLocation

  @State private var cameraPosition: MapCameraPosition

  init(strikeLocation: CLLocation) {
    self.strikeLocation = strikeLocation

    // Offset the camera center to the left so the strike appears on the right
    let offsetLongitude = strikeLocation.coordinate.longitude - 0.005
    let offsetCenter = CLLocationCoordinate2D(
      latitude: strikeLocation.coordinate.latitude,
      longitude: offsetLongitude
    )

    self._cameraPosition = State(
      initialValue: .region(
        MKCoordinateRegion(
          center: offsetCenter,
          latitudinalMeters: 800,
          longitudinalMeters: 800
        )
      )
    )
  }

  var body: some View {
    Map(position: .constant(cameraPosition)) {
      Annotation("", coordinate: strikeLocation.coordinate) {
        Image(systemName: "bolt.fill")
          .foregroundStyle(.yellow)
          .font(.caption)
          .padding(4)
          .background(Circle().fill(.black.opacity(0.5)))
      }
    }
    .mapStyle(.standard(elevation: .flat))
    .allowsHitTesting(false)
    .colorScheme(.dark)
  }
}
