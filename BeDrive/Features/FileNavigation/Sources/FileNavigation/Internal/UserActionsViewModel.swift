//
//  UserIconViewModel.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import Foundation
import FileModels

// UserActionsViewModel: Manages the user-specific actions state.
// Tracks whether to present the user actions.
// Provides user-related information, such as the user's full name and a formatted first letter.

class UserActionsViewModel: ObservableObject {
    @MainActor @Published var showUserActions = false
    
    let userActionText: String
    let iconLetter: String
    
    init(user: User) {
        self.userActionText = "Logged in as \(user.firstName) \(user.lastName)"
        self.iconLetter = user.firstName.firstLetterUppercased()
    }
}

extension String {
    func firstLetterUppercased() -> String {
        guard let firstCharacter = first else {
            return ""
        }
        return String(firstCharacter).uppercased()
    }
}
