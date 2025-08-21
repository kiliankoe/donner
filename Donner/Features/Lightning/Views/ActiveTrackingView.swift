import ComposableArchitecture
import CoreLocation
import SwiftUI

struct ActiveTrackingView: View {
  let store: StoreOf<LightningFeature>
  @State private var pulseAnimation = false
  @State private var elapsedTime: TimeInterval = 0
  @State private var timer: Timer?

  let distanceFormatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .naturalScale
    formatter.numberFormatter.maximumFractionDigits = 1
    return formatter
  }()

  private var currentDistance: Double {
    return elapsedTime * 343.0  // Speed of sound in m/s
  }

  private var formattedDistance: String {
    let measurement = Measurement(value: currentDistance, unit: UnitLength.meters)
    let locale = Locale.current
    if locale.measurementSystem == .metric {
      if currentDistance < 1000 {
        return distanceFormatter.string(from: measurement)
      } else {
        return distanceFormatter.string(from: measurement.converted(to: .kilometers))
      }
    } else {
      if currentDistance < 1609 {  // Less than 1 mile
        return distanceFormatter.string(from: measurement.converted(to: .yards))
      } else {
        return distanceFormatter.string(from: measurement.converted(to: .miles))
      }
    }
  }

  var body: some View {
    VStack(spacing: 30) {
      VStack(spacing: 12) {
        Image(systemName: "bolt.fill")
          .font(.system(size: 50))
          .foregroundStyle(LinearGradient.donnerLightningGradient)
          .glow(radius: 15)
          .scaleEffect(pulseAnimation ? 1.1 : 1.0)
          .animation(
            .easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)

        Text("Tracking Lightning Strike")
          .font(.title3.weight(.semibold))
          .foregroundStyle(Color.donnerTextPrimary)
      }

      if let strike = store.currentStrike {
        VStack(spacing: 16) {
          VStack(spacing: 4) {
            Text("Lightning detected at")
              .font(.caption)
              .foregroundStyle(Color.donnerTextSecondary)

            Text(strike.lightningTime, format: .dateTime.hour().minute().second())
              .font(.title2.monospacedDigit().weight(.bold))
              .foregroundStyle(LinearGradient.donnerLightningGradient)
              .glow(color: .donnerLightningGlow, radius: 5)
          }

          VStack(spacing: 8) {
            Text(String(format: "%.2f s", elapsedTime))
              .font(.system(size: 36).monospacedDigit().weight(.heavy))
              .foregroundStyle(Color.donnerTextPrimary)

            Text(formattedDistance)
              .font(.title3.weight(.semibold))
              .foregroundStyle(Color.donnerAccent)
          }
        }
      }

      VStack(spacing: 16) {
        Button {
          store.send(.thunderButtonTapped)
        } label: {
          HStack {
            Image(systemName: "waveform")
              .font(.title2)
            Text("I heard thunder!")
              .font(.title3.weight(.semibold))
          }
          .foregroundStyle(.black)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(LinearGradient.donnerButtonGradient)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .glow(color: .donnerLightningGlow, radius: 8)
        }

        Button {
          store.send(.resetButtonTapped)
        } label: {
          Text("Cancel")
            .font(.callout.weight(.medium))
            .foregroundStyle(Color.donnerTextSecondary)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Color.donnerCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }
    }
    .padding(28)
    .background(Color.donnerCardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(LinearGradient.donnerLightningGradient.opacity(0.2), lineWidth: 1)
    )
    .onAppear {
      pulseAnimation = true
      startTimer()
    }
    .onDisappear {
      stopTimer()
    }
  }

  private func startTimer() {
    elapsedTime = 0
    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
      if let strike = store.currentStrike {
        elapsedTime = Date().timeIntervalSince(strike.lightningTime)
      }
    }
  }

  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
}
