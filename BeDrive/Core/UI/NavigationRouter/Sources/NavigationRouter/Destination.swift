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
    
    public static func ==(lhs: Destination, rhs:Destination) -> Bool {
        switch lhs {
        case .fileHome(let lhUser):
            switch rhs {
            case .fileHome(let rhUser):
                return lhUser == rhUser
            default:
                return false
            }
        case .login:
            switch rhs {
            case .login:
                return true
            default:
                return false
            }
        }
        
    }
}
