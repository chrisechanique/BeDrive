//
//  BeDriveApp.swift
//  BeDrive
//
//  Created by Chris Echanique on 20/11/23.
//

import SwiftUI

@main
struct BeDriveApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = LoginViewModel(repository: BeDriveRepository(apiClient: APIClient()))
            LoginView(viewModel: viewModel)
        }
    }
}
