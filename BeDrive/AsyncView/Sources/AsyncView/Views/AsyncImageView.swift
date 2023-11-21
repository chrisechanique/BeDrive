//
//  AsyncImageView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 9/11/23.
//

import SwiftUI

public struct AsyncImageView: View {
    @ObservedObject var viewModel: AsyncLoadableViewModel<UIImage>

    public init(loadTask: @escaping () async throws -> UIImage) {
        self.viewModel = AsyncLoadableViewModel(fetchData: loadTask)
    }

    public var body: some View {
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
            try await Task.sleep(nanoseconds: 2_000_000_000)
            let imageURL = URL(string: "https://example.com/image.jpg")!
            let imageData = try Data(contentsOf: imageURL)
            return UIImage(data: imageData)!
        }
    }
}
