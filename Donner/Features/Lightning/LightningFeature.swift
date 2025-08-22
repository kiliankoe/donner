import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation
import Foundation
import GRDB
import SharingGRDB

@Reducer
struct LightningFeature {
  @ObservableState
  struct State {
    @FetchAll
    var persistentStrikes: [PersistentStrike] = []

    var strikes: [Strike] {
      persistentStrikes
        .map { $0.toStrike() }
        .sorted { $0.lightningTime > $1.lightningTime }
    }

    var currentStrike: Strike?
    var isTracking = false
    var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    var strikeBeingRecordedForHeading: Strike.ID?
    var showingStrikeMap = false
    var selectedStrikeForMap: Strike.ID?

    // Get all strikes that belong to the same storm as the selected strike
    var strikesForMap: [Strike] {
      guard let selectedId = selectedStrikeForMap,
        let selectedStrike = strikes.first(where: { $0.id == selectedId })
      else { return [] }

      // Find the storm group this strike belongs to
      var stormStrikes: [Strike] = [selectedStrike]
      let sortedStrikes = strikes.sorted { $0.lightningTime < $1.lightningTime }

      guard let selectedIndex = sortedStrikes.firstIndex(where: { $0.id == selectedId }) else {
        return [selectedStrike]
      }

      // Add newer strikes that are within 1 hour gaps
      var currentIndex = selectedIndex + 1
      while currentIndex < sortedStrikes.count {
        let currentStrike = sortedStrikes[currentIndex]
        let previousStrike = sortedStrikes[currentIndex - 1]
        let timeDiff = currentStrike.lightningTime.timeIntervalSince(previousStrike.lightningTime)

        if timeDiff <= 3600 {  // Within 1 hour of previous strike
          stormStrikes.append(currentStrike)
          currentIndex += 1
        } else {
          break  // Gap too large, different storm
        }
      }

      // Add older strikes that are within 1 hour gaps
      currentIndex = selectedIndex - 1
      while currentIndex >= 0 {
        let currentStrike = sortedStrikes[currentIndex]
        let nextStrike = sortedStrikes[currentIndex + 1]
        let timeDiff = nextStrike.lightningTime.timeIntervalSince(currentStrike.lightningTime)

        if timeDiff <= 3600 {  // Within 1 hour gap
          stormStrikes.append(currentStrike)
          currentIndex -= 1
        } else {
          break  // Gap too large, different storm
        }
      }

      return stormStrikes
    }
  }

  enum Action {
    case lightningButtonTapped
    case thunderButtonTapped
    case resetButtonTapped
    case deleteStrike(Strike.ID)
    case clearStrikeLocationData(Strike.ID)
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
  @Dependency(\.defaultDatabase) var database

  var body: some ReducerOf<Self> {
    Reduce { state, action -> Effect<Action> in
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
        state.currentStrike = nil
        state.isTracking = false

        return .run { _ in
          let persistentStrike = PersistentStrike(from: strike)
          try await database.write { db in
            try persistentStrike.save(db)
          }
        }

      case .resetButtonTapped:
        state.currentStrike = nil
        state.isTracking = false
        return .none

      case .deleteStrike(let id):
        return .run { _ in
          try await database.write { db in
            try db.execute(
              sql: "DELETE FROM persistentStrike WHERE id = ?",
              arguments: [id.uuidString]
            )
          }
        }

      case .clearStrikeLocationData(let id):
        return .run { _ in
          try await database.write { db in
            if let persistentStrike =
              try PersistentStrike
              .fetchOne(
                db, sql: "SELECT * FROM persistentStrike WHERE id = ?",
                arguments: [id.uuidString])
            {
              var updatedStrike = persistentStrike.toStrike()
              updatedStrike.direction = nil
              updatedStrike.userLocation = nil
              let updatedPersistentStrike = PersistentStrike(from: updatedStrike)
              try updatedPersistentStrike.update(db)
            }
          }
        }

      case .recordHeadingForStrike(let id):
        state.strikeBeingRecordedForHeading = id
        return .none

      case .headingCaptured(let strikeId, let heading, let location):
        state.strikeBeingRecordedForHeading = nil

        return .run { _ in
          try await database.write { db in
            if let persistentStrike =
              try PersistentStrike
              .fetchOne(
                db, sql: "SELECT * FROM persistentStrike WHERE id = ?",
                arguments: [strikeId.uuidString])
            {
              var updatedStrike = persistentStrike.toStrike()
              updatedStrike.direction = heading
              updatedStrike.userLocation = location
              let updatedPersistentStrike = PersistentStrike(from: updatedStrike)
              try updatedPersistentStrike.update(db)
            }
          }
        }

      case .cancelHeadingCapture:
        state.strikeBeingRecordedForHeading = nil
        return .none

      case .strikeTapped(let id):
        // Only show map if the strike has location data
        if let strike = state.strikes.first(where: { $0.id == id }),
          strike.estimatedStrikeLocation != nil
        {
          state.selectedStrikeForMap = id
          state.showingStrikeMap = true
        }
        return .none

      case .dismissStrikeMap:
        state.showingStrikeMap = false
        state.selectedStrikeForMap = nil
        return .none

      case .locationPermissionResponse(let status):
        state.locationPermissionStatus = status
        return .none

      case .locationUpdated(let location):
        if state.currentStrike != nil {
          state.currentStrike?.lightningLocation = location
        }
        return .none

      case .directionUpdated(let heading):
        if state.currentStrike != nil {
          state.currentStrike?.direction = heading
        }
        return .none
      }
    }
  }
}
