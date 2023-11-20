//
//  File.swift
//  
//
//  Created by Chris Echanique on 20/11/23.
//

import Foundation

class AsyncLoadableViewModel<SomeData> : ObservableObject, DataLoadable {
    @MainActor @Published public var dataState = DataLoadingState.empty(message: nil)
    @MainActor @Published public var data: SomeData?
    
    private let fetchData: () async throws -> SomeData
    
    init(fetchData: @escaping () async throws -> SomeData) {
        self.fetchData = fetchData
    }
    
    @MainActor public func fetch() {
        if self.dataState != .resolved {
            self.dataState = .loading(message: "Loading...")
        }
        Task {
            do{
                let data = try await fetchData()
                DispatchQueue.main.async {
                    self.data = data
                    self.dataState = .resolved
                }
            } catch {
                self.dataState = .error(message: error.localizedDescription)
            }
        }
    }
}
