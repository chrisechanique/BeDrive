//
//  UserIconView.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import SwiftUI
import FileModels
import FileRepository

struct UserActionsButton: View {
    @StateObject var viewModel: UserActionsViewModel
    
    init(user: User, repository: any FileRepository) {
        _viewModel = StateObject(wrappedValue: UserActionsViewModel(user: user, repository: repository))
    }
    
    var body: some View {
        Button(action: {
            viewModel.showUserActions = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.accent)
                    .frame(width: 32, height: 32)
                
                Text(viewModel.iconLetter)
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
        .actionSheet(isPresented: $viewModel.showUserActions, content: {
            logoutActionSheet()
        })
    }
    
    func logoutActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text(viewModel.userActionText),
            buttons: [
                .default(Text("Log out"), action: {
                    Task {
                        await viewModel.logout()
                    }
                }),
                .cancel()
            ]
        )
    }
}
