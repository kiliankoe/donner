import SwiftUI
import ComposableArchitecture

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
