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

public class BeDriveAppRouter: Routing, ObservableObject {
    @Published public var destination: Destination = .login
    
    private let authentication: Authentication = BeDriveAuthentication()
    private var repository: BeDriveRepository?
    
    public func view(for destination: Destination) -> AnyView {
        switch destination {
        case .login:
            let viewModel = UserLoginViewModel(authentication: authentication, router: self)
            return AnyView(UserLoginView<Self>(viewModel: viewModel))
        case .fileHome(let user):
            let repository = self.repository ?? BeDriveRepository(user: user)
            self.repository = repository
            let viewModel = FileNavigationViewModel(currentUser: user, repository: repository)
            return AnyView(FileNavigationView<Self>(viewModel: viewModel))
        }
    }
}
