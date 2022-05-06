//
//  MineSweeperApp.swift
//  Shared
//
//  Created by Klajd Deda on 5/1/22.
//

import SwiftUI
import ComposableArchitecture

@main
struct MineSweeperApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store: GridState.liveStore)
//            ContentViewV2()
//            ContentViewV1()
        }
    }
}
