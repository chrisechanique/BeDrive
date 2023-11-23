//
//  ContentView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 8/11/23.
//

import SwiftUI
import APIClient
import Authentication
import NavigationRouter

public struct UserLoginView<Router>: View where Router: Routing {
    @StateObject var viewModel: UserLoginViewModel
    @EnvironmentObject var router: Router
    
    public init(viewModel: UserLoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                TitleView()
                Spacer()
                VStack {
                    UsernameInput()
                    PasswordInput()
                }
                LoginButton()
                ErrorText()
                Spacer()
                Spacer()
            }
        }
        .padding(40.0)
        .preferredColorScheme(.dark)
    }
    
    private func UsernameInput() -> some View {
        TextField("Username", text: $viewModel.userName)
            .keyboardType(.namePhonePad)
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
        .disabled(viewModel.loginDisabled)
    }
    
    private func TitleView() -> some View {
        VStack(spacing: 5) {
            Text("BeDrive://")
                .font(.system(size: 46))
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
            Text("Your files for real.")
                .font(.system(size: 26))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        
    }
    
    private func ErrorText() -> (some View)? {
        switch viewModel.loginState {
        case .error(let message):
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.red)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .center)
        default:
            nil
        }
    }
}

#Preview {    
    let viewModel = UserLoginViewModel(authentication: BeDriveAuthentication(apiClient: BaseAPIClient()), router: SimpleRouter())
    return UserLoginView<SimpleRouter>(viewModel: viewModel)
}
