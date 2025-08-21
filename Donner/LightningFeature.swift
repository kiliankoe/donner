import ComposableArchitecture
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
    }

    enum Action {
        case lightningButtonTapped
        case thunderButtonTapped
        case resetButtonTapped
        case deleteStrike(Strike.ID)
        case locationPermissionResponse(CLAuthorizationStatus)
        case locationUpdated(CLLocation)
        case directionUpdated(heading: Double)
    }

    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid

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

struct Strike: Equatable, Identifiable {
    let id: UUID
    let lightningTime: Date
    var lightningLocation: CLLocation?
    var thunderTime: Date?
    var direction: Double?

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
}
