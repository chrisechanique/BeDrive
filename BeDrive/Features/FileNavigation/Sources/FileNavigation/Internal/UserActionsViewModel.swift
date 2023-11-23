//
//  UserIconViewModel.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import Foundation
import FileModels

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
