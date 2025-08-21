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
    }
    
    enum Action {
        case onAppear
        case onDisappear
        case recordButtonTapped
        case cancelButtonTapped
        case locationManager(LocationManager.Action)
    }
    
    @Dependency(\.locationManager) var locationManager
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await locationManager.requestWhenInUseAuthorization()
                    await locationManager.startUpdatingHeading()
                    await locationManager.startUpdatingLocation()

                    for await action in await locationManager.delegate() {
                        await send(.locationManager(action))
                    }
                }
                
            case .onDisappear:
                return .run { _ in
                    await locationManager.stopUpdatingHeading()
                    await locationManager.stopUpdatingLocation()
                }
                
            case .recordButtonTapped:
                // This will be handled by parent
                return .run { _ in
                    await dismiss()
                }
                
            case .cancelButtonTapped:
                return .run { _ in
                    await dismiss()
                }
                
            case let .locationManager(.didUpdateHeading(heading)):
                state.currentHeading = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
                state.isCalibrated = heading.headingAccuracy >= 0
                return .none
                
            case let .locationManager(.didUpdateLocations(locations)):
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
