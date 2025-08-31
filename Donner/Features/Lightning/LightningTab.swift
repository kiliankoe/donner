import ComposableArchitecture
import SwiftUI

struct LightningTab: View {
  let store: StoreOf<LightningFeature>

  var body: some View {
    ZStack {
      LinearGradient.donnerBackgroundGradient
        .ignoresSafeArea()

      VStack(spacing: 0) {
        HStack {
          Spacer()
          InfoIconButton()
        }
        .padding()

        ZStack {
          if store.isTracking {
            TrackingButton(store: store)
          } else {
            RecordingButton(store: store)
          }

          VStack {
            Spacer()

            if !store.isTracking, let lastStrike = store.strikes.first {
              StrikeRow(strike: lastStrike, store: store, showTip: false)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
          }
          .animation(.easeOut(duration: 0.3), value: store.isTracking)
        }
      }
    }
  }
}
