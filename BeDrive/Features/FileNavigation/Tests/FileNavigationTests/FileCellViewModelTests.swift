//
//  FileCellViewModelTests.swift
//
//
//  Created by Chris Echanique on 22/11/23.
//

import XCTest
@testable import FileNavigation
@testable import FileModels

class FileCellViewModelTests: XCTestCase {

    func testFileCellViewModelInitialization_Folder() {
        let folder = Folder(id: "1", name: "Folder", modificationDate: Date(), parentId: nil)

        let fileCellViewModel = FileCellViewModel(file: folder)

        XCTAssertEqual(fileCellViewModel.name, "Folder")
        XCTAssertEqual(fileCellViewModel.icon, .folder)
        XCTAssertNotNil(fileCellViewModel.date)
        XCTAssertNil(fileCellViewModel.size)
    }

    func testFileCellViewModelInitialization_ImageFile() {
        let imageFile = ImageFile(id: "2", name: "Image.jpg", modificationDate: Date(), parentId: "1", size: 1024)

        let fileCellViewModel = FileCellViewModel(file: imageFile)

        XCTAssertEqual(fileCellViewModel.name, "Image.jpg")
        XCTAssertEqual(fileCellViewModel.icon, .image)
        XCTAssertNotNil(fileCellViewModel.date)
        XCTAssertEqual(fileCellViewModel.size, "1.00 KB")
    }

    func testFileCellViewModelInitialization_TextFile() {
        let textFile = TextFile(id: "3", name: "Document.txt", modificationDate: Date(), parentId: "1", size: 2048)

        let fileCellViewModel = FileCellViewModel(file: textFile)

        XCTAssertEqual(fileCellViewModel.name, "Document.txt")
        XCTAssertEqual(fileCellViewModel.icon, .text)
        XCTAssertNotNil(fileCellViewModel.date)
        XCTAssertEqual(fileCellViewModel.size, "2.00 KB")
    }
}
