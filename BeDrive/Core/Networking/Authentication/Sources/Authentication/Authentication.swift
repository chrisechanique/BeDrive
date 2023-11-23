//
//  Authentication.swift
//  
//
//  Created by Chris Echanique on 22/11/23.
//

import Foundation
import FileModels

public protocol Authentication {
    func login(with userName: String, password: String) async throws -> User
    func logout() async throws
}
