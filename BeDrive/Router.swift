//
//  Router.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import SwiftUI
import FileRepository
import FileModels

enum Destination {
    case login
    case fileHome(user: User)
}
extension Destination: Equatable {
    public static func ==(lhs: Destination, rhs:Destination) -> Bool {
        switch lhs {
        case .fileHome(let lhUser):
            switch rhs {
            case .fileHome(let rhUser):
                return lhUser == rhUser
            default:
                return false
            }
        case .login:
            switch rhs {
            case .login:
                return true
            default:
                return false
            }
        }
        
    }
}

protocol Routing: ObservableObject {
    var destination: Destination { get set }
    var isLoggedIn: Bool { get set }
    func view(for destination: Destination) -> AnyView
}

class BeDriveAppRouter: Routing, ObservableObject {
    @Published var destination: Destination = .login
    @Published var isLoggedIn = false
    private let authentication: Authentication = BeDriveAuthentication()
    private var repository: BeDriveRepository?
    func view(for destination: Destination) -> AnyView {
        switch destination {
        case .login:
            let viewModel = LoginViewModel(authentication: authentication, router: self)
            return AnyView(LoginView<Self>(viewModel: viewModel))
        case .fileHome(let user):
            let repository = self.repository ?? BeDriveRepository(user: user)
            self.repository = repository
            let viewModel = FileNavigationViewModel(currentUser: user, repository: repository)
            return AnyView(FileNavigationView<Self>(viewModel: viewModel))
        }
    }
}
