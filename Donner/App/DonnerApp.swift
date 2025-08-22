import ComposableArchitecture
import GRDB
import SharingGRDB
import SwiftUI
import TipKit

@main
struct DonnerApp: App {
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  init() {
    prepareDependencies {
      do {
        let database = try DatabaseQueue.makeDefault()
        $0.defaultDatabase = database
      } catch {
        print("Failed to initialize database: \(error)")
      }
    }

    //    #if DEBUG
    //    try? Tips.resetDatastore()
    //    #endif

    try? Tips.configure([
      .displayFrequency(.immediate),
      .datastoreLocation(.applicationDefault),
    ])
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: Self.store)
    }
  }
}
