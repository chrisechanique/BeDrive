//
//  AsyncLoadableViewTests.swift
//  
//
//  Created by Chris Echanique on 21/11/23.
//

import XCTest
import SwiftUI
@testable import AsyncView

final class AsyncLoadableViewTests: XCTestCase {
    
    // MARK: - Mock View Model
    
    class MockViewModel: DataLoadable {
        
        @Published var dataState: DataLoadingState = .empty(message: nil)
        
        func load() async {
            // Simulate data loading
            try! await Task.sleep(nanoseconds: 1_000_000_000)
            self.dataState = .resolved
        }
    }
    
    // MARK: - Tests
    
    func testContentViewIsDisplayed() {
        // Given
        let viewModel = MockViewModel()
        let contentView: some View = Text("Main Content")
        
        // When
        let asyncLoadableView = AsyncLoadableView(viewModel: viewModel, contentView: { contentView })
        
        // Then
        XCTAssertTrue(asyncLoadableView.body is _ConditionalContent<Text, VStack<Image>>)
    }
    
    func testDataStateEmpty() {
        // Given
        let viewModel = MockViewModel()
        viewModel.dataState = .empty(message: "No data available")
        let contentView: some View = Text("Main Content")
        
        // When
        let asyncLoadableView = AsyncLoadableView(viewModel: viewModel, contentView: { contentView })
        
        // Then
        XCTAssertTrue(asyncLoadableView.body is _ConditionalContent<VStack<Text>, VStack<Image>>)
    }
    
    func testDataStateLoading() {
        // Given
        let viewModel = MockViewModel()
        viewModel.dataState = .loading(message: "Loading...")
        let contentView: some View = Text("Main Content")
        
        // When
        let asyncLoadableView = AsyncLoadableView(viewModel: viewModel, contentView: { contentView })
        
        // Then
        XCTAssertTrue(asyncLoadableView.body is _ConditionalContent<ProgressView <Text, Text>, VStack<Image>>)
    }
    
    func testDataStateResolved() {
        // Given
        let viewModel = MockViewModel()
        viewModel.dataState = .resolved
        let contentView: some View = Text("Main Content")
        
        // When
        let asyncLoadableView = AsyncLoadableView(viewModel: viewModel, contentView: { contentView })
        
        // Then
        XCTAssertTrue(asyncLoadableView.body is _ConditionalContent<Spacer, VStack<Image>>)
    }
    
    func testDataStateError() {
        // Given
        let viewModel = MockViewModel()
        viewModel.dataState = .error(message: "Error loading data")
        let contentView: some View = Text("Main Content")
        
        // When
        let asyncLoadableView = AsyncLoadableView(viewModel: viewModel, contentView: { contentView })
        
        // Then
        XCTAssertTrue(asyncLoadableView.body is _ConditionalContent<VStack<HStack<Image, Text>>, VStack<Image>>)
    }
}
