import ComposableArchitecture
import SwiftUI

struct StrikesListTab: View {
  let store: StoreOf<LightningFeature>

  var body: some View {
    NavigationView {
      ZStack {
        LinearGradient.donnerBackgroundGradient
          .ignoresSafeArea()

        if store.strikes.isEmpty {
          EmptyStrikesState()
        } else {
          StrikesList(store: store)
        }
      }
      .navigationTitle("strikes_navigation_title")
      .navigationBarTitleDisplayMode(.large)
    }
    .navigationViewStyle(.stack)
  }
}

private struct EmptyStrikesState: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "bolt.slash")
        .font(.system(size: 60))
        .foregroundStyle(Color.donnerTextSecondary.opacity(0.5))

      Text("no_strikes_recorded")
        .font(.title3)
        .foregroundStyle(Color.donnerTextSecondary)

      Text("tap_lightning_tab_hint")
        .font(.callout)
        .foregroundStyle(Color.donnerTextSecondary.opacity(0.7))
        .multilineTextAlignment(.center)
    }
    .padding()
  }
}
