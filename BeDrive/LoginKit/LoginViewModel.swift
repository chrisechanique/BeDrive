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
    
    let repository: FileRepository

    init(repository: FileRepository) {
        self.repository = repository
    }
    
    @MainActor
    func signIn() async {
        guard loginState != .loading else { return }
        loginState = .loading
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            loggedInUser = try await repository.login(with: userName, password: password)
            loginState = .loggedIn
        } catch {
            loginState = .error(message: error.localizedDescription)
        }
    }
}
