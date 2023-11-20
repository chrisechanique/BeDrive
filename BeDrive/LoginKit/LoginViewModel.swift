//
//  LoginViewModel.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 15/11/23.
//

import Foundation

class LoginViewModel: ObservableObject {
    enum LoginState {
        case normal
        case loading
        case loggedIn
        case failed(error:Error)
    }
    
    @Published var userName = "noel"
    @Published var password = "foobar"
    @Published var errorMessage = ""
    @Published var hasError = false
    @Published var isLoggedIn = false
    @Published var loginState = LoginState.normal
    @Published var currentUser: User?
    
    let repository: FileRepository

    init(repository: FileRepository) {
        self.repository = repository
    }
    
    func signIn() async {
        do {
            let userSession = try await repository.login(with: userName, password: password)
            DispatchQueue.main.async {
                self.currentUser = userSession.currentUser
                self.loginState = .loggedIn
                self.isLoggedIn = true
            }
        } catch {
            loginState = .failed(error: error)
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
}
