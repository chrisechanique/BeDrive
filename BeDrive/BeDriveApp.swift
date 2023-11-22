//
//  BeDriveApp.swift
//  BeDrive
//
//  Created by Chris Echanique on 20/11/23.
//

import SwiftUI
import NavigationRouter

@main
struct BeDriveApp: App {
    var body: some Scene {
        WindowGroup {
            AppRouterView(router: BeDriveAppRouter())
                .preferredColorScheme(.dark)
        }
    }
}
