import ComposableArchitecture
import CoreLocation
import Foundation
import MapKit

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

      var ageInHours: Double {
        Date().timeIntervalSince(endTime) / 3600
      }

      // Calculate opacity based on age (0-24 hours maps to 1.0-0.3 opacity)
      var opacity: Double {
        let maxAge: Double = 24  // hours
        let minOpacity: Double = 0.3
        let maxOpacity: Double = 1.0

        if ageInHours >= maxAge {
          return minOpacity
        }

        let normalizedAge = ageInHours / maxAge
        return maxOpacity - (normalizedAge * (maxOpacity - minOpacity))
      }

      // Calculate color based on age
      var color: (red: Double, green: Double, blue: Double) {
        let opacity = self.opacity
        // Interpolate from yellow (recent) to gray (old)
        if opacity > 0.7 {
          // Recent: bright yellow
          return (red: 1.0, green: 0.85, blue: 0.3)
        } else if opacity > 0.5 {
          // Medium: orange-ish
          return (red: 1.0, green: 0.7, blue: 0.4)
        } else {
          // Old: grayish
          return (red: 0.7, green: 0.7, blue: 0.7)
        }
      }
    }

    // Group strikes into storms based on time proximity
    var storms: [Storm] {
      guard !strikes.isEmpty else { return [] }

      let sortedStrikes = strikes.sorted { $0.lightningTime < $1.lightningTime }
      var storms: [Storm] = []
      var currentStormStrikes: [Strike] = []

      for strike in sortedStrikes {
        if let lastStrike = currentStormStrikes.last {
          let timeDiff = strike.lightningTime.timeIntervalSince(lastStrike.lightningTime)

          if timeDiff > 3600 {  // More than 1 hour gap
            // Start a new storm
            if !currentStormStrikes.isEmpty {
              storms.append(Storm(strikes: currentStormStrikes))
            }
            currentStormStrikes = [strike]
          } else {
            // Add to current storm
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
