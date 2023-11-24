//
//  UserLoginViewModelTests.swift
//
//
//  Created by Chris Echanique on 23/11/23.
//

import XCTest
@testable import UserLogin
@testable import Authentication
@testable import FileModels
@testable import NavigationRouter
import SwiftUI


final class UserLoginViewModelTests: XCTestCase {
    enum MockAuthError: Error {
        case genericError
    }
    class MockSuccessAuthentication: Authentication {
        func login(with userName: String, password: String) async throws -> User {
            let folder = Folder(id: "1", name: "Folder", modificationDate: Date(), parentId: nil)
            return User(firstName: userName, lastName: userName, userName: userName, password: password, rootFolder: folder)
        }
        
        func logout() async throws {}
    }
    
    class MockFailureAuthentication: Authentication {
        func login(with userName: String, password: String) async throws -> User {
            throw MockAuthError.genericError
        }
        
        func logout() async throws {
            throw MockAuthError.genericError
        }
    }

    class MockRouter: Routing {
        var destination: NavigationRouter.Destination = .login
        init() {}
        
        func view(for destination: NavigationRouter.Destination) -> AnyView {
            AnyView(Text("Mock Text"))
        }
    }

    func testInitialization() {
        let mockAuthentication = MockSuccessAuthentication()
        let mockRouter = MockRouter()

        let viewModel = UserLoginViewModel(authentication: mockAuthentication, router: mockRouter)

        XCTAssertEqual(viewModel.userName, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertEqual(viewModel.loginState, .normal)
        XCTAssertTrue(viewModel.loginDisabled)
    }

    func testSignInSuccess() async {
        let mockAuthentication = MockSuccessAuthentication()
        let mockRouter = MockRouter()
        let viewModel = UserLoginViewModel(authentication: mockAuthentication, router: mockRouter)
        viewModel.userName = "Beyonce"
        viewModel.password = "Knowles"

        await viewModel.signIn()

        XCTAssertEqual(viewModel.loginState, .loggedIn)
        XCTAssertFalse(viewModel.loginDisabled)
    }

    func testSignInFailure() async {
        let mockAuthentication = MockFailureAuthentication()
        let mockRouter = MockRouter()
        let viewModel = UserLoginViewModel(authentication: mockAuthentication, router: mockRouter)

        await viewModel.signIn()

        XCTAssertEqual(viewModel.loginState, .error(message: MockAuthError.genericError.localizedDescription))
    }

    // Add more tests as needed
}
