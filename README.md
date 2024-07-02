# BeDrive - SwiftUI File Management App

BeDrive is a SwiftUI-based iOS application for file management. It enables users to log in, navigate through their files hosted on a server, create new folders, upload images and text documents, and delete existing items.

## Features

- **Login:** Securely log in using your BeDrive credentials.
- **File Navigation:** Explore your files with an intuitive user interface.
- **Create Folders:** Organize your files by creating new folders directly from the app.
- **Upload Images and Text Docs:** Easily add images and text documents to your file system.
- **Delete Items:** Remove unwanted files or folders effortlessly by tapping and holding on a given item.

## Swift Development Choices

### SwiftUI Framework

The BeDrive app is built using SwiftUI, Apple's modern and declarative UI framework. SwiftUI provides a concise and expressive syntax for building user interfaces, enhancing developer productivity and improving code readability.

### Asynchronous Programming with Async/Await

Leveraging Swift's new concurrency model, BeDrive utilizes async/await for handling asynchronous tasks efficiently. This allows for smooth and responsive user interactions, especially when dealing with network requests.

### MVVM Architecture

BeDrive adopts the Model-View-ViewModel (MVVM) architecture, separating concerns and promoting a clear structure. View models handle business logic and interact with repositories, while views focus on presenting data and user interactions.

### Router for View Navigation

To enhance flexibility in presenting views, BeDrive employs a Router in combination with the MVVM architecture. The `NavigationRouter` manages navigation within the app, determining which view to present based on user actions.

### Dependency Injection

BeDrive follows the principle of dependency injection, promoting modularity and testability. Concrete classes, such as `BeDriveFileRepository` and `BeDriveAuthentication`, are injected at the app level, allowing for easy replacement and testing.

### Swift Package Manager (SPM)

Dependencies are managed using Swift Package Manager, simplifying the integration of external libraries and ensuring a streamlined and standardized approach to package management.

### Structured Concurrency

Swift's structured concurrency model is embraced for handling concurrent tasks in a structured and controlled manner. This helps prevent common concurrency issues and ensures a more predictable flow of execution.

## Project Structure

The BeDrive project is organized into several key components, each serving a specific purpose in the application's architecture. Understanding the project structure is essential for developers contributing to or extending the functionality of BeDrive.

![Project Structure](./BeDriveAppDiagram.png)

### Components

- **APIClient:** Manages API endpoints, authentication, and handles network requests.
- **FileRepository:** Acts as a bridge between the local file caches and the API, handling data retrieval, storage, and mapping API responses to file models.
- **FileNavigation:** Manages the file navigation experience, presenting the grid view, handling data loading and file deletion. It interacts with the repository to fetch and display file data.
- **UserLogin:** Manages user login experience, utilizes async/await for asynchronous tasks, and navigates to the file home view upon successful login.
- **Authentication:** Provides authentication services, allowing users to log in and out.
- **FileModels:** Contains the data models representing files, folders, and other related entities. Used by the repository and view models to represent and manipulate file-related data.
- **NavigationRouter:** Manages navigation within the app, determining which view to present based on the user's actions.
- **DataCache:** Manages the caching of data associated with files, optimizing the retrieval and storage of file data.
- **FileCache:** Provides a local cache for file-related data, optimizing performance by storing and retrieving files locally.

This organized project structure allows for clear separation of concerns, making the codebase modular, maintainable, and scalable. Developers can focus on specific areas of the app without getting overwhelmed by unnecessary complexity.

## Getting Started

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/BeDrive.git
   ```
2. Open the Xcode project:
   ```sh
   cd BeDrive
   open BeDrive.xcodeproj
   ```
3. Build and run the BeDrive app in Xcode.
