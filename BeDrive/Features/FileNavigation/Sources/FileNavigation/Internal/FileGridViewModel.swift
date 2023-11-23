//
//  FileGridViewModel.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 17/11/23.
//

import Foundation
import AsyncView
import FileCache
import FileModels
import FileRepository

class FileGridViewModel: ObservableObject, DataLoadable {
    @MainActor @Published var fileItems: [any FileItem] = []
    @MainActor @Published var dataState: DataLoadingState = .empty(message: nil)
    @MainActor @Published var errorMessage: String? = nil
    let folder: Folder
    let repository: FileRepository
    
    init(folder: Folder, repository: FileRepository) {
        self.folder = folder
        self.repository = repository
    }
    
    func subscribeToFileUpdates() async {
        for await items in await repository.getFileCache(for: folder).$files.values {
            await MainActor.run(body: {
                fileItems = items
                dataState = items.count == 0 ? .empty(message: "Folder is empty") : .resolved
            })
        }
    }
    
    @MainActor
    func load() async {
        // Set the loading state only if data has not been resolved
        if fileItems.count == 0 {
            dataState = .loading(message: "Loading...")
        }
        do {
            let files = try await repository.fetchFiles(in: folder)
            fileItems = files
            dataState = files.count == 0 ? .empty(message: "Folder is empty") : .resolved
        } catch {
            dataState = .error(message: error.localizedDescription)
        }
        Task {
            await subscribeToFileUpdates()
        }
    }
    
    @MainActor
    func delete(_ fileItem: any FileItem) async {
        do {
            let _ = try await repository.deleteItem(fileItem)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
