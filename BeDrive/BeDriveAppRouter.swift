//
//  Router.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import SwiftUI
import NavigationRouter
import Authentication
import FileModels
import FileRepository
import UserLogin
import FileNavigation

// App level router that implements and injects concrete service classes (ie Authentication & FileRepository) for dependency injection

public class BeDriveAppRouter: Routing, ObservableObject {
    @Published public var destination: Destination = .login
    
    private let authentication: Authentication = BeDriveAuthentication()
    private var repository: BeDriveRepository?
    
    public func view(for destination: Destination) -> AnyView {
        switch destination {
        case .login:
            let viewModel = UserLoginViewModel(authentication: authentication, router: self)
            // Returns a UserLoginView using this classes as the concrete router type
            return AnyView(UserLoginView<Self>(viewModel: viewModel))
        case .fileHome(let user):
            let repository = BeDriveRepository(user: user)
            let viewModel = FileNavigationViewModel(currentUser: user, repository: repository)
            // Returns a FileNavigationView using this classes as the concrete router type
            return AnyView(FileNavigationView<Self>(viewModel: viewModel))
        }
    }
}
