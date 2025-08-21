import CoreLocation
import Foundation

struct Strike: Equatable, Identifiable {
  let id: UUID
  let lightningTime: Date
  var lightningLocation: CLLocation?
  var thunderTime: Date?
  var direction: Double?
  var userLocation: CLLocation?

  var distance: Double? {
    guard let thunderTime = thunderTime else { return nil }
    let timeInterval = thunderTime.timeIntervalSince(lightningTime)
    return timeInterval * 343.0
  }

  var distanceInKilometers: Double? {
    guard let distance = distance else { return nil }
    return distance / 1000.0
  }

  var distanceInMiles: Double? {
    guard let distance = distance else { return nil }
    return distance * 0.000621371
  }

  var duration: TimeInterval? {
    guard let thunderTime = thunderTime else { return nil }
    return thunderTime.timeIntervalSince(lightningTime)
  }

  var estimatedStrikeLocation: CLLocation? {
    guard let distance = distance,
      let direction = direction,
      let userLocation = userLocation
    else { return nil }

    let bearing = direction * .pi / 180
    let earthRadius = 6371000.0
    let angularDistance = distance / earthRadius

    let lat1 = userLocation.coordinate.latitude * .pi / 180
    let lon1 = userLocation.coordinate.longitude * .pi / 180

    let lat2 = asin(
      sin(lat1) * cos(angularDistance) + cos(lat1) * sin(angularDistance) * cos(bearing))
    let lon2 =
      lon1
      + atan2(
        sin(bearing) * sin(angularDistance) * cos(lat1),
        cos(angularDistance) - sin(lat1) * sin(lat2))

    let newLat = lat2 * 180 / .pi
    let newLon = lon2 * 180 / .pi

    return CLLocation(latitude: newLat, longitude: newLon)
  }
}
