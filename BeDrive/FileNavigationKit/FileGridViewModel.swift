//
//  FileGridViewModel.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 17/11/23.
//

import Foundation
import AsyncView
import FileModels
import FileCache
import FileRepository

class FileGridViewModel: ObservableObject, DataLoadable {
    @MainActor @Published var fileItems: [any FileItem] = []
    @MainActor @Published var dataState: DataLoadingState = .empty(message: nil)
    @MainActor @Published var showFolderActionsAlert = false
    @MainActor @Published var showDocumentPicker = false
    @MainActor @Published var selectedFileUrl: URL? {
        didSet {
            guard let selectedFileUrl else { return }
            Task {
                await didSelectFileURL(selectedFileUrl)
            }
        }
    }
    
    let folder: Folder
    let repository: FileRepository
    var fileCache: FileCache?
    
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
            let _ = try await repository.fetchFiles(in: folder)
        } catch {
            dataState = .error(message: error.localizedDescription)
        }
        Task {
            await subscribeToFileUpdates()
        }
    }
}

extension FileGridViewModel {
    func didSelectFileURL(_ url: URL) async {
        guard url.startAccessingSecurityScopedResource() else { return }
        do {
            let name = url.lastPathComponent
            let data = try Data(contentsOf: url)
            _ = try await repository.createDataItem(in: folder, name: name, data: data)
        } catch {
            print("Error reading file data: \(error)")
        }
        url.stopAccessingSecurityScopedResource()
    }
}
