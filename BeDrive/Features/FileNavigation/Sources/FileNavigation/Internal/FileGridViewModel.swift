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

// FileGridViewModel: Manages the data for the FileGridView.
// Conforms to the DataLoadable protocol for handling loading, error, and resolved states.
// Tracks fileItems, dataState, and errorMessage as published properties for UI updates.
// Utilizes repository methods for fetching, deleting, and subscribing to file updates.
// Implements load() to fetch files, subscribeToFileUpdates() for real-time updates, and delete() for file deletion.

class FileGridViewModel: ObservableObject, DataLoadable {
    @MainActor @Published var fileItems: [any FileItem] = []
    @MainActor @Published var dataState: DataLoadingState = .loading(message: "Loading...")
    @MainActor @Published var errorMessage: String? = nil
    @MainActor @Published var emptyFolderMessage: String?
    var fetchError: Error?
    
    let folder: Folder
    let repository: FileRepository
    
    init(folder: Folder, repository: FileRepository) {
        self.folder = folder
        self.repository = repository
    }
    
    // The file cache is the source of truth, so let's subscribe to updates
    func subscribeToFileUpdates() async {
        for await items in await repository.getFileCache(for: folder).$files.values {
            await MainActor.run(body: {
                fileItems = items
                updateDataState()
            })
        }
    }
    
    @MainActor 
    func updateDataState() {
        if fileItems.count > 0 {
            dataState = .resolved
            emptyFolderMessage = nil
        } else if let fetchError {
            dataState = .error(message: fetchError.localizedDescription)
            emptyFolderMessage = nil
        } else {
            dataState = .resolved
            emptyFolderMessage = "Folder is empty"
        }
    }
    
    @MainActor
    func load() async {
        do {
            _ = try await repository.fetchFiles(in: folder)
        } catch {
            fetchError = error
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
