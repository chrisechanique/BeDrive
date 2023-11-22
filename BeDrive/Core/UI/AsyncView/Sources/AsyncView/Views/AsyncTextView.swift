//
//  TextViewer.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 15/11/23.
//

import SwiftUI

public struct AsyncTextView: View {
    private let viewModel: AsyncLoadableViewModel<String>

    public init(loadTask: @escaping () async throws -> String) {
        self.viewModel = AsyncLoadableViewModel(fetchData: loadTask)
    }

    public var body: some View {
        AsyncLoadableView(viewModel: viewModel) {
            if let text = viewModel.data {
                VStack(alignment: .leading) {
                    Text(text)
                        .font(.body)
                        .multilineTextAlignment(.trailing)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .background(Color.black.opacity(0.02))
            }
        }
    }
}

struct AsyncTextView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample data for preview
        let text = "Hello, this is a text file content."
        AsyncTextView {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return text
        }
    }
}
