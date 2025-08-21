import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation
import Testing

@testable import Donner

@MainActor
struct HeadingCaptureFeatureTests {
  @Test
  func onDisappear_StopsUpdates() async {
    let strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: HeadingCaptureFeature.State(strike: strike)
    ) {
      HeadingCaptureFeature()
    } withDependencies: {
      $0.locationManager.stopUpdatingHeading = {}
      $0.locationManager.stopUpdatingLocation = {}
    }

    await store.send(.onDisappear)
  }

  @Test
  func recordButtonTapped_DoesNotChangeState() async {
    let strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: HeadingCaptureFeature.State(strike: strike)
    ) {
      HeadingCaptureFeature()
    }

    await store.send(.recordButtonTapped)
  }

  @Test
  func cancelButtonTapped_DoesNotChangeState() async {
    let strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: HeadingCaptureFeature.State(strike: strike)
    ) {
      HeadingCaptureFeature()
    }

    await store.send(.cancelButtonTapped)
  }

  @Test
  func didChangeAuthorization_UpdatesAuthorizationStatus() async {
    let strike = Strike(
      id: UUID(),
      lightningTime: Date(),
      lightningLocation: nil
    )

    let store = TestStore(
      initialState: HeadingCaptureFeature.State(strike: strike)
    ) {
      HeadingCaptureFeature()
    }

    await store.send(.locationManager(.didChangeAuthorization(.authorizedWhenInUse))) {
      $0.isLocationAuthorized = true
    }

    await store.send(.locationManager(.didChangeAuthorization(.denied))) {
      $0.isLocationAuthorized = false
    }

    await store.send(.locationManager(.didChangeAuthorization(.authorizedAlways))) {
      $0.isLocationAuthorized = true
    }
  }
}
