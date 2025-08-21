import ComposableArchitecture
import CoreLocation
import Foundation
import Testing

@testable import Donner

@MainActor
struct LightningFeatureTests {
  @Test
  func lightningButtonTapped_StartsTracking() async {
    let testDate = Date(timeIntervalSince1970: 1000)
    let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    let store = TestStore(initialState: LightningFeature.State()) {
      LightningFeature()
    } withDependencies: {
      $0.date = .constant(testDate)
      $0.uuid = .constant(testUUID)
    }

    await store.send(.lightningButtonTapped) {
      $0.currentStrike = Strike(
        id: testUUID,
        lightningTime: testDate,
        lightningLocation: nil
      )
      $0.isTracking = true
    }
  }

  @Test
  func lightningButtonTapped_WhileTracking_DoesNothing() async {
    let testDate = Date(timeIntervalSince1970: 1000)
    let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    let initialStrike = Strike(
      id: testUUID,
      lightningTime: testDate,
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: LightningFeature.State(
        currentStrike: initialStrike,
        isTracking: true
      )
    ) {
      LightningFeature()
    }

    await store.send(.lightningButtonTapped)
  }

  @Test
  func thunderButtonTapped_CompletesStrike() async {
    let lightningTime = Date(timeIntervalSince1970: 1000)
    let thunderTime = Date(timeIntervalSince1970: 1003)
    let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    let currentStrike = Strike(
      id: testUUID,
      lightningTime: lightningTime,
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: LightningFeature.State(
        currentStrike: currentStrike,
        isTracking: true
      )
    ) {
      LightningFeature()
    } withDependencies: {
      $0.date = .constant(thunderTime)
    }

    await store.send(.thunderButtonTapped) {
      var completedStrike = currentStrike
      completedStrike.thunderTime = thunderTime
      $0.strikes = [completedStrike]
      $0.currentStrike = nil
      $0.isTracking = false
    }
  }

  @Test
  func thunderButtonTapped_WithoutCurrentStrike_DoesNothing() async {
    let store = TestStore(initialState: LightningFeature.State()) {
      LightningFeature()
    }

    await store.send(.thunderButtonTapped)
  }

  @Test
  func resetButtonTapped_CancelsCurrentTracking() async {
    let testDate = Date(timeIntervalSince1970: 1000)
    let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    let currentStrike = Strike(
      id: testUUID,
      lightningTime: testDate,
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: LightningFeature.State(
        currentStrike: currentStrike,
        isTracking: true
      )
    ) {
      LightningFeature()
    }

    await store.send(.resetButtonTapped) {
      $0.currentStrike = nil
      $0.isTracking = false
    }
  }

  @Test
  func deleteStrike_RemovesFromList() async {
    let strike1 = Strike(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
      lightningTime: Date(),
      lightningLocation: nil
    )
    let strike2 = Strike(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
      lightningTime: Date(),
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: LightningFeature.State(
        strikes: [strike1, strike2]
      )
    ) {
      LightningFeature()
    }

    await store.send(.deleteStrike(strike1.id)) {
      $0.strikes = [strike2]
    }
  }

  @Test
  func recordHeadingForStrike_SetsStrikeId() async {
    let strikeId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    let store = TestStore(initialState: LightningFeature.State()) {
      LightningFeature()
    }

    await store.send(.recordHeadingForStrike(strikeId)) {
      $0.strikeBeingRecordedForHeading = strikeId
    }
  }

  @Test
  func headingCaptured_UpdatesStrike() async {
    let strikeId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    let strike = Strike(
      id: strikeId,
      lightningTime: Date(),
      lightningLocation: nil
    )
    let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
    let heading = 45.0

    let store = TestStore(
      initialState: LightningFeature.State(
        strikes: [strike],
        strikeBeingRecordedForHeading: strikeId
      )
    ) {
      LightningFeature()
    }

    await store.send(.headingCaptured(strikeId: strikeId, heading: heading, location: location)) {
      $0.strikes[0].direction = heading
      $0.strikes[0].userLocation = location
      $0.strikeBeingRecordedForHeading = nil
    }
  }

  @Test
  func cancelHeadingCapture_ClearsStrikeId() async {
    let strikeId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    let store = TestStore(
      initialState: LightningFeature.State(
        strikeBeingRecordedForHeading: strikeId
      )
    ) {
      LightningFeature()
    }

    await store.send(.cancelHeadingCapture) {
      $0.strikeBeingRecordedForHeading = nil
    }
  }

  @Test
  func strikeTapped_WithLocation_ShowsMap() async {
    let strikeId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    var strike = Strike(
      id: strikeId,
      lightningTime: Date(),
      lightningLocation: nil
    )
    strike.thunderTime = Date(timeIntervalSinceNow: 3)
    strike.direction = 45.0
    strike.userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)

    let store = TestStore(
      initialState: LightningFeature.State(
        strikes: [strike]
      )
    ) {
      LightningFeature()
    }

    await store.send(.strikeTapped(strikeId)) {
      $0.showingStrikeMap = true
    }
  }

  @Test
  func strikeTapped_WithoutLocation_DoesNotShowMap() async {
    let strikeId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    let strike = Strike(
      id: strikeId,
      lightningTime: Date(),
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: LightningFeature.State(
        strikes: [strike]
      )
    ) {
      LightningFeature()
    }

    await store.send(.strikeTapped(strikeId))
  }

  @Test
  func dismissStrikeMap_HidesMap() async {
    let store = TestStore(
      initialState: LightningFeature.State(
        showingStrikeMap: true
      )
    ) {
      LightningFeature()
    }

    await store.send(.dismissStrikeMap) {
      $0.showingStrikeMap = false
    }
  }

  @Test
  func locationPermissionResponse_UpdatesStatus() async {
    let store = TestStore(initialState: LightningFeature.State()) {
      LightningFeature()
    }

    await store.send(.locationPermissionResponse(.authorizedWhenInUse)) {
      $0.locationPermissionStatus = .authorizedWhenInUse
    }
  }

  @Test
  func locationUpdated_WhileTracking_UpdatesCurrentStrike() async {
    let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    let currentStrike = Strike(
      id: testUUID,
      lightningTime: Date(),
      lightningLocation: nil
    )
    let location = CLLocation(latitude: 37.7749, longitude: -122.4194)

    let store = TestStore(
      initialState: LightningFeature.State(
        currentStrike: currentStrike,
        isTracking: true
      )
    ) {
      LightningFeature()
    }

    await store.send(.locationUpdated(location)) {
      $0.currentStrike?.lightningLocation = location
    }
  }

  @Test
  func locationUpdated_WithoutCurrentStrike_DoesNothing() async {
    let location = CLLocation(latitude: 37.7749, longitude: -122.4194)

    let store = TestStore(initialState: LightningFeature.State()) {
      LightningFeature()
    }

    await store.send(.locationUpdated(location))
  }

  @Test
  func directionUpdated_WhileTracking_UpdatesCurrentStrike() async {
    let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    let currentStrike = Strike(
      id: testUUID,
      lightningTime: Date(),
      lightningLocation: nil
    )
    let heading = 90.0

    let store = TestStore(
      initialState: LightningFeature.State(
        currentStrike: currentStrike,
        isTracking: true
      )
    ) {
      LightningFeature()
    }

    await store.send(.directionUpdated(heading: heading)) {
      $0.currentStrike?.direction = heading
    }
  }

  @Test
  func directionUpdated_WithoutCurrentStrike_DoesNothing() async {
    let heading = 90.0

    let store = TestStore(initialState: LightningFeature.State()) {
      LightningFeature()
    }

    await store.send(.directionUpdated(heading: heading))
  }
}
