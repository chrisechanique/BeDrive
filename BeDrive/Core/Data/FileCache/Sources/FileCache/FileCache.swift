//
//  FileCache.swift
//  BeDrive
//
//  Created by Chris Echanique on 20/11/23.
//

import Foundation
import FileModels
import Foundation

/// An actor class responsible for caching and managing files within a specified folder.
public actor FileCache {
    /// Published property to observe changes in the stored files.
    @Published public private(set) var files = [any FileItem]()
    
    /// The root folder associated with this file cache.
    private let folder: Folder
    
    /// Initializes the file cache with a specified root folder.
    ///
    /// - Parameter folder: The root folder.
    public init(folder: Folder) {
        self.folder = folder
    }
    
    /// Adds a file to the cache.
    ///
    /// - Parameter file: The file item to be added.
    public func add(_ file: any FileItem) {
        files.append(file)
    }
    
    /// Deletes a file from the cache.
    ///
    /// - Parameter file: The file item to be deleted.
    public func delete(_ file: any FileItem) {
        // Remove all items with matching id
        files.removeAll { item in
            return item.id == file.id
        }
    }
    
    /// Sets the files in the cache to the provided array.
    ///
    /// - Parameter files: The array of file items to set.
    public func set(_ files: [any FileItem]) {
        self.files = files
    }
}
