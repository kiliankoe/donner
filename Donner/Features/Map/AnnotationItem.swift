import CoreLocation
import Foundation

struct AnnotationItem: Identifiable {
  let id = UUID()
  let strike: Strike
  let storm: MapFeature.State.Storm

  var coordinate: CLLocationCoordinate2D {
    guard let location = strike.estimatedStrikeLocation else {
      return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    return location.coordinate
  }
}
