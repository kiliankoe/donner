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
                        StrikeRow(strike: strike, store: store)
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
            .sheet(item: Binding(
                get: { 
                    store.strikeBeingRecordedForHeading.flatMap { id in
                        store.strikes.first(where: { $0.id == id })
                    }
                },
                set: { _ in
                    store.send(.cancelHeadingCapture)
                }
            )) { strike in
                HeadingCaptureView(
                    store: Store(initialState: HeadingCaptureFeature.State(strike: strike)) {
                        HeadingCaptureFeature()
                    },
                    onRecordHeading: { heading, location in
                        store.send(.headingCaptured(strikeId: strike.id, heading: heading, location: location))
                    },
                    onCancel: {
                        store.send(.cancelHeadingCapture)
                    }
                )
            }
            .sheet(isPresented: Binding(
                get: { store.showingStrikeMap },
                set: { _ in store.send(.dismissStrikeMap) }
            )) {
                StrikeMapView(strikes: store.strikes)
            }
        }
    }
}
