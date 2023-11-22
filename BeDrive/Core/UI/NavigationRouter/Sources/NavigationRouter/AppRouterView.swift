//
//  AppRootView.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import SwiftUI

public struct AppRouterView<Router>: View where Router: Routing {
    @StateObject public var router: Router
    
    public init(router: Router) {
        _router = StateObject(wrappedValue: router)
    }
    
    public var body: some View {
        // Show login screen as base view
        router.view(for: .login)
            .fullScreenCover(isPresented: .constant(router.destination.isFileHome)){
                // Present file home view as full screen cover
                router.view(for: router.destination)
            }
            .environmentObject(router)
    }
}

private extension Destination {
    var isFileHome: Bool {
        switch self {
        case .fileHome(_):
            return true
        case .login:
            return false
        }
    }
}
