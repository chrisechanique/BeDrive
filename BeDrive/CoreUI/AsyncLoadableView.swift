//
//  FileGridContainerView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import SwiftUI

enum DataLoadingState: Equatable {
    case empty(message: String?)
    case loading(message: String)
    case resolved
    case error(message: String)
}

protocol DataLoadable: ObservableObject {
    var dataState: DataLoadingState { get set }
    func fetch()
}

class LoadableViewModel<SomeData> : ObservableObject, DataLoadable {
    @MainActor @Published var dataState = DataLoadingState.empty(message: nil)
    @MainActor @Published var data: SomeData?
    
    private let fetchData: () async throws -> SomeData
    
    init(fetchData: @escaping () async throws -> SomeData) {
        self.fetchData = fetchData
    }
    
    @MainActor func fetch() {
        if self.dataState != .resolved {
            self.dataState = .loading(message: "Loading...")
        }
        Task {
            do{
                let data = try await fetchData()
                DispatchQueue.main.async {
                    withAnimation {
                        self.data = data
                        self.dataState = .resolved
                    }
                }
            } catch {
                self.dataState = .error(message: error.localizedDescription)
            }
        }
    }
}

struct AsyncLoadableView<Content, ViewModel> : View where Content : View, ViewModel : DataLoadable {
    @ObservedObject var viewModel: ViewModel
    
    let content: () -> Content
    
    @inlinable public init(viewModel: ViewModel, @ViewBuilder content: @escaping () -> Content) {
        self.viewModel = viewModel
        self.content = content
    }
    
    var body: some View {
        ZStack {
            content()
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
