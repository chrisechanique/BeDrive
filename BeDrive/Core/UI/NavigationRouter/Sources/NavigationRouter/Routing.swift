//
//  Routing.swift
//  BeDrive
//
//  Created by Chris Echanique on 22/11/23.
//

import SwiftUI

public protocol Routing: ObservableObject {
    var destination: Destination { get set }
    func view(for destination: Destination) -> AnyView
}

public class SimpleRouter: Routing {
    public var destination: Destination
    
    public init(destination: Destination = .login) {
        self.destination = destination
    }
    
    public func view(for destination: Destination) -> AnyView {
        switch destination {
        case .login:
            AnyView(Text("Login"))
        case .fileHome(_):
            AnyView(Text("Home"))
        }
    }
    
    
}
