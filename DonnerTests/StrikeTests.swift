import CoreLocation
import Foundation
import Testing

@testable import Donner

struct StrikeTests {
  @Test
  func distance_CalculatesCorrectly() {
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1003)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime

    #expect(strike.distance == 1029.0)
  }

  @Test
  func distance_ReturnsNil_WhenThunderTimeNil() {
    let strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )

    #expect(strike.distance == nil)
  }

  @Test
  func distanceInKilometers_CalculatesCorrectly() {
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1003)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime

    #expect(strike.distanceInKilometers == 1.029)
  }

  @Test
  func distanceInKilometers_ReturnsNil_WhenDistanceNil() {
    let strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )

    #expect(strike.distanceInKilometers == nil)
  }

  @Test
  func distanceInMiles_CalculatesCorrectly() {
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1005.82)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime

    let expectedMiles = 5.82 * 343.0 * 0.000621371
    let actualMiles = strike.distanceInMiles!
    #expect(abs(actualMiles - expectedMiles) < 0.0001)
  }

  @Test
  func distanceInMiles_ReturnsNil_WhenDistanceNil() {
    let strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )

    #expect(strike.distanceInMiles == nil)
  }

  @Test
  func duration_CalculatesCorrectly() {
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1003.5)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime

    #expect(strike.duration == 3.5)
  }

  @Test
  func duration_ReturnsNil_WhenThunderTimeNil() {
    let strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )

    #expect(strike.duration == nil)
  }

  @Test
  func estimatedStrikeLocation_CalculatesCorrectly() {
    let userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1003)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime
    strike.direction = 45.0
    strike.userLocation = userLocation

    let estimatedLocation = strike.estimatedStrikeLocation
    #expect(estimatedLocation != nil)

    if let location = estimatedLocation {
      let distance = userLocation.distance(from: location)
      #expect(abs(distance - 1029.0) < 1.0)
    }
  }

  @Test
  func estimatedStrikeLocation_ReturnsNil_WhenDistanceNil() {
    var strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )
    strike.direction = 45.0
    strike.userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)

    #expect(strike.estimatedStrikeLocation == nil)
  }

  @Test
  func estimatedStrikeLocation_ReturnsNil_WhenDirectionNil() {
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1003)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime
    strike.userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)

    #expect(strike.estimatedStrikeLocation == nil)
  }

  @Test
  func estimatedStrikeLocation_ReturnsNil_WhenUserLocationNil() {
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1003)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime
    strike.direction = 45.0

    #expect(strike.estimatedStrikeLocation == nil)
  }

  @Test
  func estimatedStrikeLocation_NorthDirection() {
    let userLocation = CLLocation(latitude: 0, longitude: 0)
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1001)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime
    strike.direction = 0.0
    strike.userLocation = userLocation

    let estimatedLocation = strike.estimatedStrikeLocation
    #expect(estimatedLocation != nil)

    if let location = estimatedLocation {
      #expect(location.coordinate.latitude > 0)
      #expect(abs(location.coordinate.longitude) < 0.001)
    }
  }

  @Test
  func estimatedStrikeLocation_EastDirection() {
    let userLocation = CLLocation(latitude: 0, longitude: 0)
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1001)

    var strike = Strike(
      id: UUID(),
      lightningTime: lightningTime,
      lightningLocation: nil
    )
    strike.thunderTime = thunderTime
    strike.direction = 90.0
    strike.userLocation = userLocation

    let estimatedLocation = strike.estimatedStrikeLocation
    #expect(estimatedLocation != nil)

    if let location = estimatedLocation {
      #expect(abs(location.coordinate.latitude) < 0.001)
      #expect(location.coordinate.longitude > 0)
    }
  }

  @Test
  func strikeEquality() {
    let id = UUID()
    let time = Date()
    let location = CLLocation(latitude: 37.7749, longitude: -122.4194)

    let strike1 = Strike(
      id: id,
      lightningTime: time,
      lightningLocation: location
    )

    let strike2 = Strike(
      id: id,
      lightningTime: time,
      lightningLocation: location
    )

    #expect(strike1 == strike2)
  }

  @Test
  func strikeInequality_DifferentId() {
    let time = Date()
    let location = CLLocation(latitude: 37.7749, longitude: -122.4194)

    let strike1 = Strike(
      id: UUID(),
      lightningTime: time,
      lightningLocation: location
    )

    let strike2 = Strike(
      id: UUID(),
      lightningTime: time,
      lightningLocation: location
    )

    #expect(strike1 != strike2)
  }
}
