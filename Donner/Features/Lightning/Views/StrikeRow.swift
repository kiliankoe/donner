import ComposableArchitecture
import SwiftUI
import TipKit

struct StrikeRow: View {
  let strike: Strike
  let store: StoreOf<LightningFeature>

  private let directionTip = DirectionRecordingTip()

  private var secondaryDistanceLabel: String {
    guard let distance = strike.distance else { return "-" }
    let measurement = Measurement(value: distance, unit: UnitLength.meters)

    let locale = Locale.current
    if locale.measurementSystem == .metric {
      return MeasurementFormatter.preciseDistance.string(
        from: measurement.converted(to: .kilometers))
    } else {
      return MeasurementFormatter.preciseDistance.string(from: measurement.converted(to: .miles))
    }
  }

  private var primaryDistanceLabel: String {
    guard let distance = strike.distance else { return "-" }
    let measurement = Measurement(value: distance, unit: UnitLength.meters)

    let locale = Locale.current
    if locale.measurementSystem == .metric {
      return MeasurementFormatter.distance.string(from: measurement)
    } else {
      return MeasurementFormatter.distance.string(from: measurement.converted(to: .yards))
    }
  }

  private var durationText: String {
    guard let duration = strike.duration else { return "-" }
    return MeasurementFormatter.duration.string(
      from: Measurement(value: duration, unit: UnitDuration.seconds))
  }

  private var hasLocation: Bool {
    strike.estimatedStrikeLocation != nil
  }

  private var isRecentStrike: Bool {
    Date().timeIntervalSince(strike.lightningTime) < 300
  }

  var body: some View {
    ZStack {
      // Layer 1: Map background (if available)
      if let strikeLocation = strike.estimatedStrikeLocation {
        StrikeRowMapBackground(strikeLocation: strikeLocation)
          .opacity(0.3)

        // Layer 2: Gradient overlay for better text contrast (only when map is shown)
        LinearGradient(
          colors: [
            Color.donnerDarkBackground.opacity(0.85),
            Color.donnerDarkBackground.opacity(0.0),
          ],
          startPoint: .leading,
          endPoint: .trailing
        )
      }

      // Layer 3: Content (HStack with text and buttons)
      HStack {
        VStack(alignment: .leading, spacing: 6) {
          HStack(spacing: 8) {
            Image(systemName: "bolt.fill")
              .font(.caption)
              .foregroundStyle(LinearGradient.donnerLightningGradient)

            Text(strike.lightningTime, format: .dateTime.hour().minute().second())
              .font(.headline.monospacedDigit())
              .foregroundStyle(Color.donnerTextPrimary)
          }

          if strike.distance != nil {
            HStack(spacing: 8) {
              Text(secondaryDistanceLabel)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.donnerAccent)

              Text("·")
                .foregroundStyle(Color.donnerTextSecondary)

              Text(durationText)
                .font(.subheadline)
                .foregroundStyle(Color.donnerTextSecondary)
            }
          }
        }

        Spacer()

        if strike.distance != nil {
          Text(primaryDistanceLabel)
            .font(.title2.monospacedDigit().weight(.bold))
            .foregroundStyle(LinearGradient.donnerLightningGradient)
            .frame(minWidth: 80, alignment: .trailing)
        }
      }
      .padding(16)
    }
    .background(hasLocation ? Color.donnerCardBackground.opacity(0.9) : Color.donnerCardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(
          hasLocation
            ? Color.donnerLightningGlow.opacity(0.3) : Color.donnerLightningGlow.opacity(0.1),
          lineWidth: 1)
    )
    .popoverTip(!hasLocation && strike.distance != nil ? directionTip : nil, arrowEdge: .top)
    .onTapGesture {
      if hasLocation {
        store.send(.strikeTapped(strike.id))
      } else if strike.distance != nil {
        store.send(.recordHeadingForStrike(strike.id))
        directionTip.invalidate(reason: .actionPerformed)
      }
    }
  }
}
