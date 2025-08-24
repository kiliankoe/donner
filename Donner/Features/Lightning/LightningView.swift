import ComposableArchitecture
import SwiftUI

struct LightningView: View {
  let store: StoreOf<LightningFeature>

  var body: some View {
    ZStack {
      LinearGradient.donnerBackgroundGradient
        .ignoresSafeArea()

      VStack(spacing: 24) {
        if store.isTracking {
          ActiveTrackingView(store: store)
            .transition(
              .asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
              ))
            .padding(.horizontal)
        } else {
          IdleView(store: store)
            .transition(
              .asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
              ))
            .padding(.horizontal)
        }

        StrikesList(store: store)
      }
      .padding(.top)
    }
    .preferredColorScheme(.dark)
  }
}
