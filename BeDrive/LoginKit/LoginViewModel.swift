//
//  LoginViewModel.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 15/11/23.
//

import Foundation
import FileRepository
import FileModels

class LoginViewModel: ObservableObject {
    enum LoginState: Equatable {
        case normal
        case loading
        case loggedIn
        case error(message: String)
    }
    
    @Published var userName = "noel" {
        didSet {
            guard userName != oldValue else { return }
            loginDisabled = userName.isEmpty || password.isEmpty
        }
    }
    @Published var password = "foobar" {
        didSet {
            guard password != oldValue else { return }
            loginDisabled = userName.isEmpty || password.isEmpty
        }
    }
    @Published var loginState = LoginState.normal
    @Published var loggedInUser: User?
    @Published var loginDisabled = false
    
    let authentication: Authentication
    let router: any Routing

    init(authentication: Authentication, router: any Routing) {
        self.authentication = authentication
        self.router = router
    }
    
    @MainActor
    func signIn() async {
        guard loginState != .loading else { return }
        loginState = .loading
        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            let user = try await authentication.login(with: userName, password: password)
            loggedInUser = user
            router.destination = .fileHome(user: user)
            router.isLoggedIn = true
            loginState = .loggedIn
        } catch {
            loginState = .error(message: error.localizedDescription)
        }
    }
}
