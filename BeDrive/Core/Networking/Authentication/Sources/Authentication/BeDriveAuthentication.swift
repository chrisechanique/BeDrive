//
//  File.swift
//  
//
//  Created by Chris Echanique on 22/11/23.
//

import Foundation
import APIClient
import FileModels

public actor BeDriveAuthentication: Authentication {
    private let apiClient: APIClient
    private var loggedInUser: User?
    
    public init(apiClient: APIClient = BaseAPIClient()) {
        self.apiClient = apiClient
    }
    
    public func login(with userName: String, password: String) async throws -> User {
        let credentials = BeDriveAPIEndpoint.Credentials(userName: userName, password: password)
        let user = try await apiClient.request(BeDriveAPIEndpoint.currentUser(credentials: credentials)) as BeDriveAPIEndpoint.User
        let folder = Folder(id: user.rootItem.id, name: user.rootItem.name, modificationDate: user.rootItem.modificationDate, parentId: user.rootItem.parentId)
        let currentUser = User(firstName: user.firstName, lastName: user.lastName, userName:userName, password: password, rootFolder: folder)
        self.loggedInUser = currentUser
        return currentUser
    }
    
    public func logout() async throws {
        self.loggedInUser = nil
    }
}
