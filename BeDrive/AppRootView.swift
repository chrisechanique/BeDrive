//
//  AppRootView.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import SwiftUI

struct AppRootView<Router>: View where Router: Routing {
    @StateObject var router: Router
    
    var body: some View {
        // Show login screen as base view
        router.view(for: .login)
            .fullScreenCover(isPresented: .constant(router.destination != .login)){
                // Present file home view as full screen cover
                router.view(for: router.destination)
            }
            .environmentObject(router)
    }
    
    private var isFileHomeDestination: Bool {
        switch router.destination {
        case .login:
            return false
        case .fileHome:
            return true
        }
    }
}
