//
//  Destination.swift
//  BeDrive
//
//  Created by Chris Echanique on 22/11/23.
//

import Foundation
import FileModels

public enum Destination: Equatable {
    case login
    case fileHome(user: User)
}
