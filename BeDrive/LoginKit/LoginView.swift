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
    
    private func EmailInput() -> some View {
        TextField("Username", text: $viewModel.userName)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
    }
    
    private func PasswordInput() -> some View {
        SecureField("Password", text: $viewModel.password)
            .textFieldStyle(.roundedBorder)
    }
    
    private func LoginButton() -> some View {
        Button(action: {
            Task {
                await viewModel.signIn()
            }
        }) {
            switch viewModel.loginState {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundStyle(Color.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            default:
                Text("Sign In")
                    .foregroundStyle(Color.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
            
        }
        .background(Color.accentColor)
        .cornerRadius(5)
    }
    
    
    
    private func TitleView() -> some View {
        Text("BeDrive://")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(Color.white)
        
    }
}

#Preview {
    let viewModel = LoginViewModel(repository: BeDriveRepository(apiClient: BaseAPIClient()))
    return LoginView(viewModel: viewModel)
}
