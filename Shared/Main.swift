import SwiftUI
import ComposableArchitecture

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {
          AppView(store: GridState.liveStore)
        }
    }
}
