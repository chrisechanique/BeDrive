//
//  FileGridContainerView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import SwiftUI

// Generic SwiftUI view that handles the presentation of data loading states.
public struct AsyncLoadableView<ContentView, ViewModel>: View where ContentView: View, ViewModel: DataLoadable {
    @ObservedObject var viewModel: ViewModel
    
    // Closure to build the main content of the view.
    let contentView: () -> ContentView
    
    // Initializes the view with a view model and content view builder.
    public init(viewModel: ViewModel, @ViewBuilder contentView: @escaping () -> ContentView) {
        self.viewModel = viewModel
        self.contentView = contentView
    }
    
    // Body of the view, presenting the main content and handling different data loading states.
    public var body: some View {
        ZStack {
            contentView()
            switch viewModel.dataState {
            case .loading(let message):
                ProgressView(message)
                    .progressViewStyle(CircularProgressViewStyle())
            case .resolved:
                Spacer()
            case .error(let message):
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                    Text(message)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
