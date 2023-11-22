//
//  UserIconViewModel.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import Foundation
import FileRepository
import FileModels

class UserActionsViewModel: ObservableObject {
    @MainActor @Published var showUserActions = false
    @MainActor @Published var showAlert = false
    @MainActor @Published var errorMessage: String? = nil
    
    let userActionText: String
    let iconLetter: String
    
    private let repository: FileRepository
    
    init(user: User, repository: FileRepository) {
        self.repository = repository
        self.userActionText = "Logged in as \(user.firstName) \(user.lastName)"
        self.iconLetter = user.firstName.firstLetterUppercased()
    }
    
    @MainActor
    func logout() async {
        
//        do {
//            _ = try await repository.logout()
//            showUserActions = false
//        } catch {
//            showAlert = true
//            errorMessage = error.localizedDescription
//        }
    }
}

private extension String {
    func firstLetterUppercased() -> String {
        guard let firstCharacter = first else {
            return ""
        }
        return String(firstCharacter).uppercased()
    }
}
