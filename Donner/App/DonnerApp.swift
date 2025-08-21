import SwiftUI
import ComposableArchitecture
import TipKit

@main
struct DonnerApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
//            ._printChanges()
    }

    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
