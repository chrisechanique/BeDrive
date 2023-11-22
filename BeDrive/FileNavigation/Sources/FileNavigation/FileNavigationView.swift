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
import NavigationRouter

public struct FileNavigationView<Router>: View where Router: Routing {
    @StateObject var viewModel: FileNavigationViewModel
    
    public init(viewModel: FileNavigationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
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
