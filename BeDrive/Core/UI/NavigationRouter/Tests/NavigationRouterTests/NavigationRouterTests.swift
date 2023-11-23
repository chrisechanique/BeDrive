import XCTest
import SwiftUI
import FileModels
@testable import NavigationRouter

final class NavigationRouterTests: XCTestCase {
    
    // Mock Routing implementation for testing
    class MockRouter: Routing {
        @Published var destination: Destination = .login
        
        func view(for destination: Destination) -> AnyView {
            switch destination {
            case .login:
                return AnyView(Text("Login"))
            case .fileHome:
                return AnyView(Text("FileHome"))
            }
        }
    }
}
