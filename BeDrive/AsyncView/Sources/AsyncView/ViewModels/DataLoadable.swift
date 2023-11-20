//
//  File.swift
//  
//
//  Created by Chris Echanique on 20/11/23.
//

import Foundation

public enum DataLoadingState: Equatable {
    case empty(message: String?)
    case loading(message: String)
    case resolved
    case error(message: String)
}

public protocol DataLoadable: ObservableObject {
    var dataState: DataLoadingState { get set }
    func fetch()
}
