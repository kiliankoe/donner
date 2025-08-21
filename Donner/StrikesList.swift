import SwiftUI
import ComposableArchitecture

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
