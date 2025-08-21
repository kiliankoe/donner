import SwiftUI
import CoreLocation

struct StrikeRow: View {
    let strike: Strike
    
    @State private var distanceFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    }()
    
    @State private var shortDistanceFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    
    private var primaryDistanceText: String {
        guard let distance = strike.distance else { return "-" }
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        
        // Use locale to determine primary unit
        let locale = Locale.current
        if locale.measurementSystem == .metric {
            return distanceFormatter.string(from: measurement.converted(to: .kilometers))
        } else {
            return distanceFormatter.string(from: measurement.converted(to: .miles))
        }
    }
    
    private var secondaryDistanceText: String {
        guard let distance = strike.distance else { return "-" }
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        
        // Use locale to determine secondary unit
        let locale = Locale.current
        if locale.measurementSystem == .metric {
            return shortDistanceFormatter.string(from: measurement)
        } else {
            return shortDistanceFormatter.string(from: measurement.converted(to: .yards))
        }
    }
    
    private var durationText: String {
        guard let duration = strike.duration else { return "-" }
        return String(format: "%.1f s", duration)
    }

    var body: some View {
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
                        Text(primaryDistanceText)
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
                VStack(alignment: .trailing, spacing: 2) {
                    Text(secondaryDistanceText.components(separatedBy: " ").first ?? "-")
                        .font(.title2.monospacedDigit().weight(.bold))
                        .foregroundStyle(LinearGradient.donnerLightningGradient)
                    Text(secondaryDistanceText.components(separatedBy: " ").last ?? "")
                        .font(.caption2)
                        .foregroundStyle(Color.donnerTextSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.donnerCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.donnerLightningGlow.opacity(0.1), lineWidth: 1)
        )
    }
}
