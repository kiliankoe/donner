import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var lightning = LightningFeature.State()
  }

  enum Action {
    case lightning(LightningFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.lightning, action: \.lightning) {
      LightningFeature()
    }

    Reduce { state, action in
      switch action {
      case .lightning:
        return .none
      }
    }
  }
}

struct AppView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    LightningView(
      store: store.scope(state: \.lightning, action: \.lightning)
    )
  }
}
