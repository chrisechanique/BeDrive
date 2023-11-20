//
//  FileNavigationView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import SwiftUI

class FileNavigationViewModel: ObservableObject {
    @Published var showLogoutActionsAlert = false
    let currentUser: User
    let repository: FileRepository
    
    init(currentUser: User, repository: FileRepository) {
        self.currentUser = currentUser
        self.repository = repository
    }
}

struct FileNavigationView: View {
    @ObservedObject var viewModel: FileNavigationViewModel
    
    init(viewModel: FileNavigationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            let viewModel = FileGridViewModel(folder: viewModel.currentUser.rootFolder, repository: viewModel.repository)
            AsyncLoadableView(viewModel: viewModel) {
                FileGridView(viewModel: viewModel)
            }
            .toolbar {
                userIconToolbarItem()
            }
//            .actionSheet(isPresented: $viewModel.showLogoutActionsAlert) {
//                // Present an action sheet with options
//                logoutActionSheet(with: self.viewModel.currentUser)
//            }
        }
        .preferredColorScheme(.dark)
    }
    
    func userIconToolbarItem() -> ToolbarItem<(), Button<UserIconView>> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
//                viewModel.showLogoutActionsAlert = true
            }) {
                UserIconView(name: self.viewModel.currentUser.firstName)
            }
        }
    }
    
    
    func logoutActionSheet(with user: User) -> ActionSheet {
        ActionSheet(
            title: Text("Logged in as \(user.firstName) \(user.lastName)"),
            buttons: [
                .default(Text("Log out"), action: {
                    // TODO: Add logout
                }),
                .cancel()
            ]
        )
    }
}

struct UserIconView: View {
    let name: String
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accent)
                .frame(width: 32, height: 32)
            
            Text(firstLetter(of: name))
                .foregroundColor(.white)
                .font(.headline)
        }
    }
    
    func firstLetter(of string: String) -> String {
        guard let firstCharacter = string.first else {
            return ""
        }
        return String(firstCharacter)
    }
}
