//
//  ImageCache.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 16/11/23.
//
import Foundation

// A thread-safe actor class for caching Data objects using NSCache
public actor DataCache {
    // The NSCache instance to store NSData objects with NSString keys
    private var cache = NSCache<NSString, NSData>()
    
    public init() {}

    // Async function to fetch data from the cache for a given ID
    public func loadData(for id: String) async -> Data? {
        return await object(for: id)
    }

    // Async function to store data in the cache for a given ID
    public func store(_ data: Data, for id: String) async {
        return await set(object: data, for: id)
    }

    // Async function to remove data from the cache for a given ID
    public func remove(for id: String) async {
        let nsKey = NSString(string: id)
        self.cache.removeObject(forKey: nsKey)
    }
    
    // Async function to clear all data from the cache
    public func clearAll() async {
        self.cache.removeAllObjects()
    }

    // Private helper function to retrieve a Data object for a given key
    private func object(for key: String) async -> Data? {
        let nsKey = NSString(string: key)
        guard let nsData = self.cache.object(forKey: nsKey) else {
            return nil
        }
        return Data(nsData)
    }

    // Private helper function to set a Data object for a given key in the cache
    private func set(object data: Data, for key: String) async {
        let nsKey = NSString(string: key)
        let nsData = NSData(data: data)
        self.cache.setObject(nsData, forKey: nsKey)
    }
}
