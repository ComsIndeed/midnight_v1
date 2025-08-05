# Midnight V1

Midnight is a Flutter-based application that allows users to generate quizzes and other study materials from various sources. It leverages the power of large language models to create interactive and engaging learning experiences.

## Features

* **Quiz Generation:** Generate quizzes from text, images, audio, and video files.
* **Multiple Question Types:** The app supports both multiple-choice and identification-style questions.
* **Customizable Quizzes:** Users can provide a prompt to guide the quiz generation process and specify the number of questions.
* **File Support:** Supports a wide range of file types, including PDF, images (JPG, PNG, GIF, etc.), audio (MP3, WAV, etc.), and video (MP4, MOV, etc.).
* **Cross-Platform:** Midnight is built with Flutter and is available on Android, iOS, and desktop (Windows, macOS, and Linux).

## Folder Structure

The project follows a feature-driven folder structure, where files are organized by feature rather than by type. This makes the codebase easier to navigate and maintain as the project grows.

```

.
├── android
├── assets
├── build
├── ios
├── lib
│   ├── blocs
│   │   ├── chats\_bloc
│   │   ├── quiz\_page\_bloc
│   │   └── quizzes\_bloc
│   ├── main.dart
│   ├── models
│   ├── pages
│   │   ├── chats\_page
│   │   ├── homepage
│   │   ├── quiz\_page
│   │   ├── settings\_page
│   │   └── study\_page
│   ├── repositories
│   ├── services
│   └── utils
├── linux
├── macos
├── test
└── web

````

## Getting Started

To get started with the project, clone the repository and run the following command to install the dependencies:

```bash
flutter pub get
````

Then, you can run the app on your desired platform using the following command:

```bash
flutter run
```

## Contributing

Contributions are welcome\! Please feel free to open an issue or submit a pull request if you have any suggestions or improvements.
