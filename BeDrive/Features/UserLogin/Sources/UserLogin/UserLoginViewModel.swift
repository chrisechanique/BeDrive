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

public class UserLoginViewModel: ObservableObject {
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
    @Published var loginDisabled = false
    
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
            try await Task.sleep(nanoseconds: 500_000_000)
            let user = try await authentication.login(with: userName, password: password)
            router.destination = .fileHome(user: user)
            loginState = .loggedIn
        } catch {
            loginState = .error(message: error.localizedDescription)
        }
    }
}
