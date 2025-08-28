import ComposableArchitecture
import SwiftUI

struct LightningTab: View {
  let store: StoreOf<LightningFeature>

  var body: some View {
    ZStack {
      LinearGradient.donnerBackgroundGradient
        .ignoresSafeArea()

      VStack {
        HStack {
          Spacer()
          InfoIconButton()
        }
        .padding()

        Spacer()

        if store.isTracking {
          TrackingButton(store: store)
        } else {
          RecordingButton(store: store)
        }

        Spacer()
      }
    }
  }
}

struct RecordingButton: View {
  let store: StoreOf<LightningFeature>
  @State private var sparkTrigger = 0
  @State private var pulseAnimation = false
  @State private var lightningButtonTapped = false

  var body: some View {
    GeometryReader { geometry in
      let buttonSize = min(geometry.size.width, geometry.size.height) * 0.8

      VStack {
        Spacer()
        HStack {
          Spacer()

          Button {
            lightningButtonTapped.toggle()
            store.send(.lightningButtonTapped)
          } label: {
            ZStack {
              Circle()
                .fill(LinearGradient.donnerButtonGradient)
                .frame(width: buttonSize, height: buttonSize)
                .overlay(
                  Circle()
                    .stroke(
                      LinearGradient.donnerLightningGradient.opacity(0.3),
                      lineWidth: 2
                    )
                )
                .glow(color: .donnerLightningGlow, radius: 30)
                .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                .animation(
                  .easeInOut(duration: 2).repeatForever(autoreverses: true),
                  value: pulseAnimation
                )

              VStack(spacing: 20) {
                Image(systemName: "bolt.fill")
                  .font(.system(size: buttonSize * 0.25))
                  .foregroundStyle(.black.opacity(0.8))

                Text("i_saw_flash")
                  .font(.system(size: buttonSize * 0.08).weight(.bold))
                  .foregroundStyle(.black.opacity(0.8))
              }

              ElectricSparkEffect(trigger: sparkTrigger)
                .scaleEffect(2.5)
            }
          }
          .sensoryFeedback(.warning, trigger: lightningButtonTapped)

          Spacer()
        }
        Spacer()
      }
      .onAppear {
        pulseAnimation = true
      }
    }
  }
}

struct TrackingButton: View {
  let store: StoreOf<LightningFeature>
  @State private var pulseAnimation = false
  @State private var elapsedTime: TimeInterval = 0
  @State private var timer: Timer?
  @State private var thunderTapped = false
  @State private var cancelTapped = false

  private var currentDistance: Double {
    return elapsedTime * 343.0  // Speed of sound in m/s
  }

  private var formattedDistance: String {
    let measurement = Measurement(value: currentDistance, unit: UnitLength.meters)
    let locale = Locale.current
    if locale.measurementSystem == .metric {
      if currentDistance < 1000 {
        return MeasurementFormatter.distance.string(from: measurement)
      } else {
        return MeasurementFormatter.distance.string(from: measurement.converted(to: .kilometers))
      }
    } else {
      if currentDistance < 1609 {  // Less than 1 mile
        return MeasurementFormatter.distance.string(from: measurement.converted(to: .yards))
      } else {
        return MeasurementFormatter.distance.string(from: measurement.converted(to: .miles))
      }
    }
  }

  var body: some View {
    GeometryReader { geometry in
      let buttonSize = min(geometry.size.width, geometry.size.height) * 0.8

      ZStack {
        Button {
          thunderTapped.toggle()
          store.send(.thunderButtonTapped)
        } label: {
          ZStack {
            Circle()
              .fill(LinearGradient.donnerButtonGradient)
              .frame(width: buttonSize, height: buttonSize)
              .overlay(
                Circle()
                  .stroke(
                    LinearGradient.donnerLightningGradient.opacity(0.5),
                    lineWidth: 3
                  )
              )
              .glow(color: .donnerLightningGlow, radius: 40)
              .scaleEffect(pulseAnimation ? 1.05 : 1.0)
              .animation(
                .easeInOut(duration: 1).repeatForever(autoreverses: true),
                value: pulseAnimation
              )

            VStack(spacing: 16) {
              Image(systemName: "waveform")
                .font(.system(size: buttonSize * 0.15))
                .foregroundStyle(.black.opacity(0.8))

              if let strike = store.currentStrike {
                VStack(spacing: 8) {
                  Text("lightning_detected_at")
                    .font(.system(size: buttonSize * 0.04))
                    .foregroundStyle(.black.opacity(0.6))

                  Text(strike.lightningTime, format: .dateTime.hour().minute().second())
                    .font(.system(size: buttonSize * 0.06).monospacedDigit().weight(.semibold))
                    .foregroundStyle(.black.opacity(0.8))
                }
              }

              VStack(spacing: 4) {
                Text(
                  MeasurementFormatter.preciseTime.string(
                    from: Measurement(value: elapsedTime, unit: UnitDuration.seconds))
                )
                .font(.system(size: buttonSize * 0.12).monospacedDigit().weight(.heavy))
                .foregroundStyle(.black.opacity(0.9))

                Text(formattedDistance)
                  .font(.system(size: buttonSize * 0.08).weight(.semibold))
                  .foregroundStyle(.black.opacity(0.7))
              }
            }
          }
        }
        .sensoryFeedback(.success, trigger: thunderTapped)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        VStack {
          Spacer()
          Button {
            cancelTapped.toggle()
            store.send(.resetButtonTapped)
          } label: {
            Text("cancel")
              .font(.callout.weight(.medium))
              .foregroundStyle(Color.donnerTextSecondary)
              .padding(.horizontal, 24)
              .padding(.vertical, 8)
              .background(Color.donnerCardBackground)
              .clipShape(RoundedRectangle(cornerRadius: 8))
          }
          .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: cancelTapped)
          .padding(.bottom, 40)
        }
      }
      .onAppear {
        pulseAnimation = true
        startTimer()
      }
      .onDisappear {
        stopTimer()
      }
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

struct InfoIconButton: View {
  @State private var showingInfo = false

  var body: some View {
    Button {
      showingInfo = true
    } label: {
      Image(systemName: "info.circle.fill")
        .font(.title2)
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(Color.donnerTextSecondary)
    }
    .sheet(isPresented: $showingInfo) {
      InfoView(isPresented: $showingInfo)
    }
  }
}
