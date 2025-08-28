import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
  @ObservableState
  struct State {
    var lightning = LightningFeature.State()
    var selectedTab = Tab.lightning

    enum Tab {
      case lightning
      case strikes
      case map
    }
  }

  enum Action {
    case lightning(LightningFeature.Action)
    case tabSelected(State.Tab)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.lightning, action: \.lightning) {
      LightningFeature()
    }

    Reduce { state, action in
      switch action {
      case .lightning:
        return .none
      case .tabSelected(let tab):
        state.selectedTab = tab
        return .none
      }
    }
  }
}

struct AppView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
      LightningTab(
        store: store.scope(state: \.lightning, action: \.lightning)
      )
      .tabItem {
        Label("tab_lightning", systemImage: "bolt.fill")
      }
      .tag(AppFeature.State.Tab.lightning)

      StrikesListTab(
        store: store.scope(state: \.lightning, action: \.lightning)
      )
      .tabItem {
        Label("tab_strikes", systemImage: "list.bullet")
      }
      .tag(AppFeature.State.Tab.strikes)

      MapTab(
        store: store.scope(state: \.lightning, action: \.lightning)
      )
      .tabItem {
        Label("tab_map", systemImage: "map.fill")
      }
      .tag(AppFeature.State.Tab.map)
    }
    .tint(Color.donnerLightning)
    .preferredColorScheme(.dark)
  }
}
