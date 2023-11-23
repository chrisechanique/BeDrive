//
//  UserActionsViewModelTests.swift
//  
//
//  Created by Chris Echanique on 23/11/23.
//

import XCTest
@testable import FileNavigation
@testable import FileModels

final class UserActionsViewModelTests: XCTestCase {

    func testInitialization() async {
        let user = User(firstName: "Beyonce", lastName: "Knowles", userName: "bey", password: "yonce", rootFolder: Folder(id: "1", name: "Root", modificationDate: Date(), parentId: nil))

        let viewModel = UserActionsViewModel(user: user)

        let showUserActions = await viewModel.showUserActions
        
        XCTAssertFalse(showUserActions)
        XCTAssertEqual(viewModel.userActionText, "Logged in as Beyonce Knowles")
        XCTAssertEqual(viewModel.iconLetter, "B")
    }
    
    func testFirstLetterUppercased() {
        let inputString = "hello"

        let result = inputString.firstLetterUppercased()

        XCTAssertEqual(result, "H")
    }
    
    func testFirstLetterUppercased_EmptyString() {
        let inputString = ""

        let result = inputString.firstLetterUppercased()

        XCTAssertEqual(result, "")
    }
}
