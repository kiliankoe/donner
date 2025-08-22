import ComposableArchitecture
import CoreLocation
import MapKit
import SwiftUI
import TipKit

struct StrikeRow: View {
  let strike: Strike
  let store: StoreOf<LightningFeature>

  private let directionTip = DirectionRecordingTip()

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
        StrikeMapBackground(strikeLocation: strikeLocation)
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

        if !hasLocation && strike.distance != nil {
          Button {
            store.send(.recordHeadingForStrike(strike.id))
            directionTip.invalidate(reason: .actionPerformed)
          } label: {
            Image(systemName: "location.north.line.fill")
              .font(.title3)
              .foregroundStyle(LinearGradient.donnerLightningGradient)
              .padding(8)
              .background(Color.donnerCardBackground.opacity(0.5))
              .clipShape(Circle())
              .overlay(
                Circle()
                  .stroke(Color.donnerLightningGlow.opacity(0.2), lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
          .popoverTip(directionTip, arrowEdge: .trailing)
        }

        if strike.distance != nil {
          VStack(alignment: .trailing, spacing: 2) {
            Text(secondaryDistanceText.components(separatedBy: " ").first ?? "-")
              .font(.title2.monospacedDigit().weight(.bold))
              .foregroundStyle(LinearGradient.donnerLightningGradient)
            Text(secondaryDistanceText.components(separatedBy: " ").last ?? "")
              .font(.caption2)
              .foregroundStyle(Color.donnerTextSecondary)
          }
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
    .onTapGesture {
      if hasLocation {
        store.send(.strikeTapped(strike.id))
      }
    }
  }
}

struct StrikeMapBackground: View {
  let strikeLocation: CLLocation

  @State private var cameraPosition: MapCameraPosition

  init(strikeLocation: CLLocation) {
    self.strikeLocation = strikeLocation

    // Offset the camera center to the left so the strike appears on the right
    let offsetLongitude = strikeLocation.coordinate.longitude - 0.005
    let offsetCenter = CLLocationCoordinate2D(
      latitude: strikeLocation.coordinate.latitude,
      longitude: offsetLongitude
    )

    self._cameraPosition = State(
      initialValue: .region(
        MKCoordinateRegion(
          center: offsetCenter,
          latitudinalMeters: 800,
          longitudinalMeters: 800
        )
      )
    )
  }

  var body: some View {
    Map(position: .constant(cameraPosition)) {
      Annotation("", coordinate: strikeLocation.coordinate) {
        Image(systemName: "bolt.fill")
          .foregroundStyle(.yellow)
          .font(.caption)
          .padding(4)
          .background(Circle().fill(.black.opacity(0.5)))
      }
    }
    .mapStyle(.standard(elevation: .flat))
    .allowsHitTesting(false)
    .colorScheme(.dark)
  }
}
