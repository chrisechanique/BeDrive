//
//  UserIconView.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import SwiftUI
import FileModels
import FileRepository
import NavigationRouter

// UserActionsButton: Represents a button for user-specific actions such as logout.
// Utilizes UserActionsViewModel to manage state and initiate actions.

struct UserActionsButton<Router>: View where Router: Routing {
    @EnvironmentObject var router: Router
    @StateObject var viewModel: UserActionsViewModel
    
    init(user: User, repository: any FileRepository) {
        _viewModel = StateObject(wrappedValue: UserActionsViewModel(user: user))
    }
    
    var body: some View {
        Button(action: {
            viewModel.showUserActions = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
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
                    router.destination = .login
                }),
                .cancel()
            ]
        )
    }
}
