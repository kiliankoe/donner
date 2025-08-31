import ComposableArchitecture
import CoreLocation
import Foundation
import MapKit
import SwiftUI

@Reducer
struct MapFeature {
  @ObservableState
  struct State: Equatable {
    var strikes: [Strike] = []
    var selectedStrike: Strike.ID?
    var mapRegion: MapRegion?

    struct MapRegion: Equatable {
      let center: CLLocationCoordinate2D
      let span: MKCoordinateSpan

      static func == (lhs: MapRegion, rhs: MapRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude && lhs.center.longitude == rhs.center.longitude
          && lhs.span.latitudeDelta == rhs.span.latitudeDelta
          && lhs.span.longitudeDelta == rhs.span.longitudeDelta
      }
    }

    struct Storm: Identifiable {
      let id = UUID()
      var strikes: [Strike]
      var startTime: Date {
        strikes.map(\.lightningTime).min() ?? Date()
      }
      var endTime: Date {
        strikes.map(\.lightningTime).max() ?? Date()
      }

      var ageInDays: Int {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: endTime, to: now).day ?? 0
        return days
      }

      var isToday: Bool {
        Calendar.current.isDateInToday(endTime)
      }

      var isThisWeek: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        return endTime >= weekAgo
      }

      var opacity: Double {
        if isToday {
          return 1.0
        } else if isThisWeek {
          return 0.75
        } else {
          return 0.6
        }
      }

      var color: Color {
        if isToday {
          return .donnerStrikeToday
        } else if isThisWeek {
          return .donnerStrikeThisWeek
        } else {
          return .donnerStrikeOlder
        }
      }
    }

    // Group strikes into storms based on day groups (4am cutoff)
    var storms: [Storm] {
      guard !strikes.isEmpty else { return [] }

      let sortedStrikes = strikes.sorted { $0.lightningTime < $1.lightningTime }
      var storms: [Storm] = []
      var currentStormStrikes: [Strike] = []

      for strike in sortedStrikes {
        if let lastStrike = currentStormStrikes.last {
          if !strike.lightningTime.belongsToSameDayGroup(as: lastStrike.lightningTime) {
            // Different day group, start a new storm
            if !currentStormStrikes.isEmpty {
              storms.append(Storm(strikes: currentStormStrikes))
            }
            currentStormStrikes = [strike]
          } else {
            // Same day group, add to current storm
            currentStormStrikes.append(strike)
          }
        } else {
          // First strike
          currentStormStrikes = [strike]
        }
      }

      // Add the last storm
      if !currentStormStrikes.isEmpty {
        storms.append(Storm(strikes: currentStormStrikes))
      }

      return storms.sorted { $0.startTime > $1.startTime }
    }
  }

  enum Action {
    case strikeSelected(Strike.ID?)
    case updateMapRegion(State.MapRegion)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .strikeSelected(let id):
        state.selectedStrike = id
        return .none

      case .updateMapRegion(let region):
        state.mapRegion = region
        return .none
      }
    }
  }
}
