import SwiftUI
import ComposableArchitecture
import CoreLocation

struct LightningView: View {
    let store: StoreOf<LightningFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if store.isTracking {
                    ActiveTrackingView(store: store)
                } else {
                    IdleView(store: store)
                }

                StrikesList(store: store)
            }
            .padding()
            .navigationTitle("Donner")
        }
    }
}

struct ActiveTrackingView: View {
    let store: StoreOf<LightningFeature>

    var body: some View {
        VStack(spacing: 30) {
            Text("Tracking Lightning Strike")
                .font(.headline)

            if let strike = store.currentStrike {
                Text("Lightning detected at:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(strike.lightningTime, style: .time)
                    .font(.title2.monospacedDigit())
            }

            Button {
                store.send(.thunderButtonTapped)
            } label: {
                Label("Thunder Heard", systemImage: "waveform")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("Cancel") {
                store.send(.resetButtonTapped)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct IdleView: View {
    let store: StoreOf<LightningFeature>

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text("Tap when you see lightning")
                .font(.headline)

            Button {
                store.send(.lightningButtonTapped)
            } label: {
                Label("Lightning Seen", systemImage: "bolt")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

struct StrikesList: View {
    let store: StoreOf<LightningFeature>

    var body: some View {
        if !store.strikes.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Strikes")
                    .font(.headline)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(store.strikes.reversed()) { strike in
                            StrikeRow(strike: strike)
                        }
                    }
                }
            }
        }
    }
}

struct StrikeRow: View {
    let strike: Strike

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(strike.lightningTime, style: .time)
                    .font(.headline.monospacedDigit())

                if let distance = strike.distanceInKilometers {
                    HStack(spacing: 8) {
                        Text(String(format: "%.1f km", distance))
                            .font(.subheadline)

                        Text("·")
                            .foregroundStyle(.secondary)

                        Text(String(format: "%.1f mi", strike.distanceInMiles ?? 0))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if let distance = strike.distance {
                Text(String(format: "%.0f m", distance))
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
