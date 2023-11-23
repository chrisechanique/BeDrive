//
//  FileNavigationViewModel.swift
//  BeDrive
//
//  Created by Chris Echanique on 22/11/23.
//

import Foundation
import FileModels
import FileRepository

// FileNavigationViewModel: Manages the current user and file repository for file navigation.

public class FileNavigationViewModel: ObservableObject {
    let currentUser: User
    let repository: FileRepository
    
    public init(currentUser: User, repository: FileRepository) {
        self.currentUser = currentUser
        self.repository = repository
    }
}
