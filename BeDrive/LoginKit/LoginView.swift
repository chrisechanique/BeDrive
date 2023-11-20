//
//  ContentView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 8/11/23.
//

import SwiftUI
import APIClient

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    fileprivate func EmailInput() -> some View {
        TextField("Username", text: $viewModel.userName)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func PasswordInput() -> some View {
        SecureField("Password", text: $viewModel.password)
            .textFieldStyle(.roundedBorder)
    }
    
    fileprivate func LoginButton() -> some View {
        Button(action: {
            Task {
                await viewModel.signIn()
            }
        }) {
            Text("Sign In")
                .foregroundStyle(Color.white)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
        .background(Color.accentColor)
        .cornerRadius(5)    }
    
    fileprivate func TitleView() -> some View {
        Text("BeDrive://")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(Color.white)
        
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            TitleView()
            Spacer()
            VStack {
                EmailInput()
                PasswordInput()
            }
            LoginButton()
            Spacer()
        }
        .padding(40.0)
        .background(Color.background)
        .fullScreenCover(isPresented: $viewModel.isLoggedIn){
            if let currentUser = viewModel.currentUser {
                let viewModel = FileNavigationViewModel(currentUser: currentUser, repository: viewModel.repository)
                FileNavigationView(viewModel: viewModel)
            }
        }
        .alert("Error", isPresented: $viewModel.hasError) {
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    let viewModel = LoginViewModel(repository: BeDriveRepository(apiClient: BaseAPIClient()))
    return LoginView(viewModel: viewModel)
}
