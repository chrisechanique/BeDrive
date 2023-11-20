//
//  AsyncImageView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 9/11/23.
//

import SwiftUI

struct AsyncImageView: View {
    private let viewModel: LoadableViewModel<UIImage>

    init(loadTask: @escaping () async throws -> UIImage) {
        self.viewModel = LoadableViewModel(fetchData: loadTask)
    }

    var body: some View {
        AsyncLoadableView(viewModel: viewModel) {
            if let uiimage = viewModel.data {
                Image(uiImage: uiimage)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageView { () async throws -> UIImage in
            // Replace with your image loading logic
            try await Task.sleep(nanoseconds: 2000000000)
            let imageURL = URL(string: "https://example.com/image.jpg")!
            let imageData = try Data(contentsOf: imageURL)
            return UIImage(data: imageData)!
        }
    }
}
