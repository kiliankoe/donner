import SwiftUI
import ComposableArchitecture
import CoreLocation

struct LightningView: View {
    let store: StoreOf<LightningFeature>

    var body: some View {
        ZStack {
            LinearGradient.donnerBackgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if store.isTracking {
                    ActiveTrackingView(store: store)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                } else {
                    IdleView(store: store)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }

                StrikesList(store: store)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}

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
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                
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
                        Text("Thunder Heard")
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

struct IdleView: View {
    let store: StoreOf<LightningFeature>
    @State private var iconRotation = false

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [
                                Color.donnerLightningGlow.opacity(0.3),
                                Color.donnerLightningGlow.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        ))
                        .frame(width: 160, height: 160)
                        .blur(radius: 10)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(LinearGradient.donnerLightningGradient)
                        .glow(radius: 20)
                        .rotationEffect(.degrees(iconRotation ? 5 : -5))
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: iconRotation)
                }

                Text("Tap when you see lightning")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.donnerTextPrimary)
            }

            Button {
                store.send(.lightningButtonTapped)
            } label: {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                    Text("Lightning Seen")
                        .font(.title3.weight(.semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(LinearGradient.donnerButtonGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .glow(color: .donnerLightningGlow, radius: 10)
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            iconRotation = true
        }
    }
}

struct StrikesList: View {
    let store: StoreOf<LightningFeature>

    var body: some View {
        if !store.strikes.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.callout)
                        .foregroundStyle(LinearGradient.donnerLightningGradient)
                    Text("Recent Strikes")
                        .font(.headline)
                        .foregroundStyle(Color.donnerTextPrimary)
                }
                .padding(.horizontal, 4)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(store.strikes.reversed().enumerated()), id: \.element.id) { index, strike in
                            StrikeRow(strike: strike)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                                .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.05), value: store.strikes.count)
                        }
                    }
                }
            }
        }
    }
}

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
