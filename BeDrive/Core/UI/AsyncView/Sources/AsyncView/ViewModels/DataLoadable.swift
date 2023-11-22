//
//  File.swift
//  
//
//  Created by Chris Echanique on 20/11/23.
//

import Foundation

// Represents the state of data loading, including cases for different loading states and optional error messages.
public enum DataLoadingState: Equatable {
    case empty(message: String?)
    case loading(message: String)
    case resolved
    case error(message: String)
}

// Protocol for objects that can be loaded with data asynchronously, providing a consistent interface for data loading.
public protocol DataLoadable: ObservableObject {
    var dataState: DataLoadingState { get set }
    func load() async
}
