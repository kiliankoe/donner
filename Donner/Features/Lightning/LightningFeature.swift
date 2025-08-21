import ComposableArchitecture
import ComposableCoreLocation
import Foundation
import CoreLocation

@Reducer
struct LightningFeature {
    @ObservableState
    struct State: Equatable {
        var strikes: [Strike] = []
        var currentStrike: Strike?
        var isTracking = false
        var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
        var strikeBeingRecordedForHeading: Strike.ID?
        var showingStrikeMap = false
    }

    enum Action {
        case lightningButtonTapped
        case thunderButtonTapped
        case resetButtonTapped
        case deleteStrike(Strike.ID)
        case recordHeadingForStrike(Strike.ID)
        case headingCaptured(strikeId: Strike.ID, heading: Double, location: CLLocation)
        case cancelHeadingCapture
        case strikeTapped(Strike.ID)
        case dismissStrikeMap
        case locationPermissionResponse(CLAuthorizationStatus)
        case locationUpdated(CLLocation)
        case directionUpdated(heading: Double)
    }

    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    @Dependency(\.locationManager) var locationManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .lightningButtonTapped:
                if state.currentStrike == nil {
                    state.currentStrike = Strike(
                        id: uuid(),
                        lightningTime: date(),
                        lightningLocation: nil
                    )
                    state.isTracking = true
                }
                return .none

            case .thunderButtonTapped:
                guard var strike = state.currentStrike else { return .none }

                strike.thunderTime = date()
                state.strikes.append(strike)
                state.currentStrike = nil
                state.isTracking = false
                return .none

            case .resetButtonTapped:
                state.currentStrike = nil
                state.isTracking = false
                return .none

            case let .deleteStrike(id):
                state.strikes.removeAll { $0.id == id }
                return .none

            case let .recordHeadingForStrike(id):
                state.strikeBeingRecordedForHeading = id
                return .none

            case let .headingCaptured(strikeId, heading, location):
                if let index = state.strikes.firstIndex(where: { $0.id == strikeId }) {
                    state.strikes[index].direction = heading
                    state.strikes[index].userLocation = location
                }
                state.strikeBeingRecordedForHeading = nil
                return .none

            case .cancelHeadingCapture:
                state.strikeBeingRecordedForHeading = nil
                return .none

            case let .strikeTapped(id):
                // Only show map if the strike has location data
                if let strike = state.strikes.first(where: { $0.id == id }),
                   strike.estimatedStrikeLocation != nil {
                    state.showingStrikeMap = true
                }
                return .none

            case .dismissStrikeMap:
                state.showingStrikeMap = false
                return .none

            case let .locationPermissionResponse(status):
                state.locationPermissionStatus = status
                return .none

            case let .locationUpdated(location):
                if state.currentStrike != nil {
                    state.currentStrike?.lightningLocation = location
                }
                return .none

            case let .directionUpdated(heading):
                if state.currentStrike != nil {
                    state.currentStrike?.direction = heading
                }
                return .none
            }
        }
    }
}
