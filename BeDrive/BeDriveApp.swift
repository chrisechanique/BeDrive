//
//  BeDriveApp.swift
//  BeDrive
//
//  Created by Chris Echanique on 20/11/23.
//

import SwiftUI
import APIClient
import FileRepository

@main
struct BeDriveApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView(router: BeDriveAppRouter())
        }
    }
}
