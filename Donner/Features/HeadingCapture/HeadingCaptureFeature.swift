import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation

@Reducer
struct HeadingCaptureFeature {
  @ObservableState
  struct State: Equatable {
    let strike: Strike
    var currentHeading: Double = 0
    var userLocation: CLLocation?
    var isCalibrated = false
    var isLocationAuthorized = false

    var isSimulator: Bool {
      #if targetEnvironment(simulator)
        return true
      #else
        return false
      #endif
    }
  }

  enum Action {
    case onAppear
    case onDisappear
    case recordButtonTapped
    case cancelButtonTapped
    case locationManager(LocationManager.Action)
  }

  @Dependency(\.locationManager) var locationManager

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        #if targetEnvironment(simulator)
          // In simulator, set dummy values
          state.currentHeading = Double.random(in: 0...360)
          state.isCalibrated = true
          // Still request location for simulator
          return .run { send in
            await locationManager.requestWhenInUseAuthorization()
            await locationManager.startUpdatingLocation()

            for await action in await locationManager.delegate() {
              await send(.locationManager(action))
            }
          }
        #else
          return .run { send in
            await locationManager.requestWhenInUseAuthorization()
            await locationManager.startUpdatingHeading()
            await locationManager.startUpdatingLocation()

            for await action in await locationManager.delegate() {
              await send(.locationManager(action))
            }
          }
        #endif

      case .onDisappear:
        return .run { _ in
          await locationManager.stopUpdatingHeading()
          await locationManager.stopUpdatingLocation()
        }

      case .recordButtonTapped:
        // Parent will handle dismissal
        return .none

      case .cancelButtonTapped:
        // Parent will handle dismissal
        return .none

      case .locationManager(.didUpdateHeading(let heading)):
        state.currentHeading =
          heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
        state.isCalibrated = heading.headingAccuracy >= 0
        return .none

      case .locationManager(.didUpdateLocations(let locations)):
        if let location = locations.last {
          state.userLocation = CLLocation(location)
        }
        return .none

      case .locationManager(.didChangeAuthorization(let status)):
        state.isLocationAuthorized = status == .authorizedWhenInUse || status == .authorizedAlways
        return .none

      case .locationManager:
        return .none
      }
    }
  }
}

// Helper to convert from ComposableCoreLocation.Location to CLLocation
extension CLLocation {
  convenience init(_ location: ComposableCoreLocation.Location) {
    self.init(
      coordinate: location.coordinate,
      altitude: location.altitude,
      horizontalAccuracy: location.horizontalAccuracy,
      verticalAccuracy: location.verticalAccuracy,
      course: location.course,
      speed: location.speed,
      timestamp: location.timestamp
    )
  }
}
