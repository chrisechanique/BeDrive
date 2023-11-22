//
//  FileNavigationView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import SwiftUI
import AsyncView
import FileModels
import FileRepository

class FileNavigationViewModel: ObservableObject {
    let currentUser: User
    let repository: FileRepository
    
    init(currentUser: User, repository: FileRepository) {
        self.currentUser = currentUser
        self.repository = repository
    }
}

struct FileNavigationView<Router>: View where Router: Routing {
    @StateObject var viewModel: FileNavigationViewModel
    
    init(viewModel: FileNavigationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            let viewModel = FileGridViewModel(folder: viewModel.currentUser.rootFolder, repository: viewModel.repository)
            AsyncLoadableView(viewModel: viewModel) {
                FileGridView(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    UserActionsButton<Router>(user: self.viewModel.currentUser, repository: viewModel.repository)
                }
            }
        }
        .preferredColorScheme(.dark)
        .environmentObject(viewModel)
    }
}
