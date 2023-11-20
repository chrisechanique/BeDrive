import SwiftUI

// MARK: - Cell Views

struct FolderCell: View {
    var name: String
    var body: some View {
        VStack {
            Image(systemName: "folder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            Text(name)
        }
        .contextMenu {
            Button(action: {
                // Action for deleting the text file
//                                    deleteAction()
            }) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}

struct ImageFileCell: View {
    var name: String
    var body: some View {
        VStack {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            Text(name)
        }
    }
}

struct TextFileCell: View {
    var name: String
    var body: some View {
        VStack {
            Image(systemName: "doc.text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            Text(name)
        }
    }
}
