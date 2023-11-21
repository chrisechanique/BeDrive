//
//  File.swift
//  
//
//  Created by Chris Echanique on 20/11/23.
//

import Foundation

// Generic view model that supports asynchronous data loading and updates its state accordingly.

class AsyncLoadableViewModel<SomeData>: ObservableObject, DataLoadable {
    @MainActor @Published public var dataState = DataLoadingState.empty(message: nil)
    @MainActor @Published public var data: SomeData?
    
    // Asynchronous function to fetch data.
    private let fetchData: () async throws -> SomeData
    
    // Initializes the view model with the asynchronous data fetch function.
    init(fetchData: @escaping () async throws -> SomeData) {
        self.fetchData = fetchData
    }
    
    // Initiates the data fetching process.
    @MainActor
    public func load() async {
        if dataState != .resolved {
            dataState = .loading(message: "Loading...")
        }
        do {
            data = try await fetchData()
            dataState = .resolved
        } catch {
            dataState = .error(message: error.localizedDescription)
        }
    }
}
