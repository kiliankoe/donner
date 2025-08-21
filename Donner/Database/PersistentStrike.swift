import CoreLocation
import Foundation
import GRDB
import SharingGRDB

@Table("persistentStrike")
struct PersistentStrike: Codable, FetchableRecord, PersistableRecord {
  let id: String
  let lightningTime: Double
  let lightningLocationLatitude: Double?
  let lightningLocationLongitude: Double?
  let thunderTime: Double?
  let direction: Double?
  let userLocationLatitude: Double?
  let userLocationLongitude: Double?

  init(from strike: Strike) {
    self.id = strike.id.uuidString
    self.lightningTime = strike.lightningTime.timeIntervalSince1970
    self.lightningLocationLatitude = strike.lightningLocation?.coordinate.latitude
    self.lightningLocationLongitude = strike.lightningLocation?.coordinate.longitude
    self.thunderTime = strike.thunderTime?.timeIntervalSince1970
    self.direction = strike.direction
    self.userLocationLatitude = strike.userLocation?.coordinate.latitude
    self.userLocationLongitude = strike.userLocation?.coordinate.longitude
  }

  func toStrike() -> Strike {
    var strike = Strike(
      id: UUID(uuidString: id) ?? UUID(),
      lightningTime: Date(timeIntervalSince1970: lightningTime),
      lightningLocation: nil
    )

    if let lat = lightningLocationLatitude, let lon = lightningLocationLongitude {
      strike.lightningLocation = CLLocation(latitude: lat, longitude: lon)
    }

    if let thunderTime = thunderTime {
      strike.thunderTime = Date(timeIntervalSince1970: thunderTime)
    }

    strike.direction = direction

    if let lat = userLocationLatitude, let lon = userLocationLongitude {
      strike.userLocation = CLLocation(latitude: lat, longitude: lon)
    }

    return strike
  }
}
