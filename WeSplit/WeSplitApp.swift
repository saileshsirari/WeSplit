//
//  WeSplitApp.swift
//  WeSplit
//
//  Created by sailesh sirari on 02/10/24.
//

import SwiftUI
import SwiftData


@main
struct WeSplitApp: App {
    var body: some Scene {
        WindowGroup {
            ImageFilterContentView()
        }
        .modelContainer(for: User.self)
    }
}
