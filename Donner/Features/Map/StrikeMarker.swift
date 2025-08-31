import CoreLocation
import SwiftUI

struct StrikeMarker: View {
  let strike: Strike
  let storm: MapFeature.State.Storm
  let isSelected: Bool

  var body: some View {
    ZStack {
      if let previousStrike = previousStrikeInStorm {
        ConnectionLine(
          from: strike.estimatedStrikeLocation!,
          to: previousStrike.estimatedStrikeLocation!,
          opacity: storm.opacity
        )
      }

      Circle()
        .fill(
          storm.color
            .opacity(storm.opacity)
        )
        .frame(width: 20, height: 20)
        .overlay(
          Image(systemName: "bolt.fill")
            .font(.caption2)
            .foregroundStyle(.black.opacity(0.7))
        )
        .overlay(
          Circle()
            .stroke(Color.white.opacity(storm.opacity * 0.8), lineWidth: 2)
        )
    }
  }

  private var previousStrikeInStorm: Strike? {
    guard let index = storm.strikes.firstIndex(where: { $0.id == strike.id }),
      index > 0
    else { return nil }

    for i in (0..<index).reversed() {
      if storm.strikes[i].estimatedStrikeLocation != nil {
        return storm.strikes[i]
      }
    }

    return nil
  }
}
