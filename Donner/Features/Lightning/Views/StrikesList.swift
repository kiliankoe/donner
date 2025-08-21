import ComposableArchitecture
import SwiftUI

struct StrikesList: View {
  let store: StoreOf<LightningFeature>

  var body: some View {
    if !store.strikes.isEmpty {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Image(systemName: "clock.arrow.circlepath")
            .font(.callout)
            .foregroundStyle(LinearGradient.donnerLightningGradient)
          Text("recent_strikes")
            .font(.headline)
            .foregroundStyle(Color.donnerTextPrimary)
        }
        .padding(.horizontal, 4)

        List {
          ForEach(Array(store.strikes.enumerated()), id: \.element.id) { index, strike in
            VStack(spacing: 0) {
              // Show divider if more than an hour between this and next older strike
              if index > 0 {
                let previousStrike = store.strikes[index - 1]
                let timeDifference = abs(
                  previousStrike.lightningTime.timeIntervalSince(strike.lightningTime))

                if timeDifference > 3600 {  // More than 1 hour
                  StormDivider()
                    .padding(.vertical, 12)
                }
              }

              StrikeRow(strike: strike, store: store)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
          }
          .onDelete { indexSet in
            for index in indexSet {
              if index < store.strikes.count {
                store.send(.deleteStrike(store.strikes[index].id))
              }
            }
          }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
      }
      .sheet(
        item: Binding(
          get: {
            store.strikeBeingRecordedForHeading.flatMap { id in
              store.strikes.first(where: { $0.id == id })
            }
          },
          set: { _ in
            store.send(.cancelHeadingCapture)
          }
        )
      ) { strike in
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
      .sheet(
        isPresented: Binding(
          get: { store.showingStrikeMap },
          set: { _ in store.send(.dismissStrikeMap) }
        )
      ) {
        StrikeMapView(strikes: store.strikesForMap)
      }
    }
  }
}
