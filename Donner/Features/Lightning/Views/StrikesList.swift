import ComposableArchitecture
import SwiftUI

struct StrikesList: View {
  let store: StoreOf<LightningFeature>

  enum ListItem: Hashable {
    case strike(Strike)
    case divider(id: String)
  }

  var listItems: [ListItem] {
    var items: [ListItem] = []

    for (index, strike) in store.strikes.enumerated() {
      items.append(.strike(strike))

      // Add divider after this strike if more than an hour to the next older strike
      if index < store.strikes.count - 1 {
        let olderStrike = store.strikes[index + 1]
        let timeDifference = strike.lightningTime.timeIntervalSince(olderStrike.lightningTime)

        if timeDifference > 3600 {  // More than 1 hour gap to older strike
          items.append(.divider(id: "\(strike.id)-divider"))
        }
      }
    }

    return items
  }

  var body: some View {
    if !store.strikes.isEmpty {
      List {
        ForEach(listItems, id: \.self) { item in
          switch item {
          case .strike(let strike):
            StrikeRow(strike: strike, store: store)
              .listRowBackground(Color.clear)
              .listRowSeparator(.hidden)
              .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
              .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                  store.send(.deleteStrike(strike.id))
                } label: {
                  Label("delete", systemImage: "trash")
                }

                if strike.estimatedStrikeLocation != nil {
                  Button {
                    store.send(.clearStrikeLocationData(strike.id))
                  } label: {
                    Label("clear_location", systemImage: "location.slash")
                  }
                  .tint(.orange)
                }
              }
              .padding(.horizontal)
          case .divider(let id):
            Group {
              if let strike = store.strikes.first(where: { "\($0.id)-divider" == id }) {
                StormDivider(date: strike.lightningTime)
              } else {
                StormDivider(date: Date())
              }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .allowsHitTesting(false)
          }
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
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
