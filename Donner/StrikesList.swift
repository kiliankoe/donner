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

                List {
                    ForEach(store.strikes.reversed()) { strike in
                        StrikeRow(strike: strike)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                    }
                    .onDelete { indexSet in
                        let reversedStrikes = Array(store.strikes.reversed())
                        for index in indexSet {
                            if index < reversedStrikes.count {
                                store.send(.deleteStrike(reversedStrikes[index].id))
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
