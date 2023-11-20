//
//  FileGridContainerView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import SwiftUI

public struct AsyncLoadableView<ContentView, ViewModel> : View where ContentView : View, ViewModel : DataLoadable {
    @ObservedObject var viewModel: ViewModel
    
    let contentView: () -> ContentView
    
    public init(viewModel: ViewModel, @ViewBuilder contentView: @escaping () -> ContentView) {
        self.viewModel = viewModel
        self.contentView = contentView
    }
    
    public var body: some View {
        ZStack {
            contentView()
            switch viewModel.dataState {
            case .empty(let message):
                if let message {
                    VStack {
                        Text(message)
                            .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color.gray)
                    }
                }
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
            viewModel.fetch()
        }
    }
    
    
}
