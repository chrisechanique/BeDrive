//
//  UserLoginViewModel.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 15/11/23.
//

import Foundation
import Authentication
import FileModels
import NavigationRouter

// UserLoginViewModel: Manages the login state and authentication logic for the user.

public class UserLoginViewModel: ObservableObject {
    enum LoginState: Equatable {
        case normal
        case loading
        case loggedIn
        case error(message: String)
    }
    
    @Published var userName = "" {
        didSet {
            guard userName != oldValue else { return }
            loginDisabled = userName.isEmpty || password.isEmpty
        }
    }
    @Published var password = "" {
        didSet {
            guard password != oldValue else { return }
            loginDisabled = userName.isEmpty || password.isEmpty
        }
    }
    @Published var loginState = LoginState.normal
    @Published var loginDisabled = true
    
    let authentication: Authentication
    let router: any Routing

    public init(authentication: Authentication, router: any Routing) {
        self.authentication = authentication
        self.router = router
    }
    
    @MainActor
    func signIn() async {
        guard loginState != .loading else { return }
        loginState = .loading
        do {
            let user = try await authentication.login(with: userName, password: password)
            router.destination = .fileHome(user: user)
            loginState = .loggedIn
        } catch {
            loginState = .error(message: error.localizedDescription)
        }
    }
}
