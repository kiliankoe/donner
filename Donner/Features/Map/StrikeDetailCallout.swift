import Foundation
import SwiftUI

struct StrikeDetailCallout: View {
  let strike: Strike
  let onDismiss: () -> Void

  var body: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Image(systemName: "bolt.fill")
            .font(.title2)
            .foregroundStyle(Color.donnerLightning)

          VStack(alignment: .leading) {
            Text(strike.lightningTime.formatted(.dateTime.weekday(.wide).month().day()))
              .font(.headline)
              .foregroundStyle(Color.donnerTextPrimary)

            Text(strike.lightningTime.formatted(.dateTime.hour().minute().second()))
              .font(.subheadline)
              .foregroundStyle(Color.donnerTextSecondary)
          }
        }

        if let distance = strike.distance {
          HStack(spacing: 4) {
            Image(systemName: "location.circle.fill")
              .font(.caption)
              .foregroundStyle(Color.donnerTextSecondary)

            let measurement = Measurement(value: distance, unit: UnitLength.meters)
            Text(
              "\(MeasurementFormatter.distance.string(from: measurement)) \(Text("strike_distance_away", bundle: .main))"
            )
            .font(.caption.monospacedDigit())
            .foregroundStyle(Color.donnerTextPrimary)
          }
        }

        if let duration = strike.duration {
          HStack(spacing: 4) {
            Image(systemName: "timer")
              .font(.caption)
              .foregroundStyle(Color.donnerTextSecondary)

            let measurement = Measurement(value: duration, unit: UnitDuration.seconds)
            Text(MeasurementFormatter.duration.string(from: measurement))
              .font(.caption.monospacedDigit())
              .foregroundStyle(Color.donnerTextPrimary)
          }
        }
      }

      Spacer()

      Button(action: onDismiss) {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
          .foregroundStyle(Color.donnerTextSecondary)
      }
    }
    .padding()
    .background(Color.donnerCardBackground.opacity(0.95))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(radius: 10)
  }
}
