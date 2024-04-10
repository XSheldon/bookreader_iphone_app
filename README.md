# Bookreader App

This app helps kids who are learning to read be autonomous in their journey and supports them in their efforts by providing the correct answer. Point to the book, take a picture, and the app will read aloud.

## Features

- **Text Extraction**: Utilize your camera to capture text from any printed source.
- **Text-to-Speech**: Convert the extracted text into speech, making information accessible even on the go.
- **Custom User Interface**: Experience a user-friendly interface designed for optimal reading.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- macOS with the latest version of Xcode installed.
- An active Apple Developer account.
- A valid Google API key with access to the Vision API for text extraction features.

### Installation

#### Clone the repository

```bash
git clone https://github.com/yourusername/bookreader.git
cd bookreader
```

### Set up the Environment Variable

The app requires a valid Google API key to access the Vision API. You must set this key as an environment variable named `GOOGLE_API_KEY` for the app to function correctly.

To use the environment variable within Xcode, edit the scheme of your app:

1. Go to `Product` > `Scheme` > `Edit Scheme...`
2. Select `Run` from the side panel.
3. Open the `Arguments` tab.
4. Under "Environment Variables," add a new variable:
   - Name: `GOOGLE_API_KEY`
   - Value: `Your actual Google API key`.

### Open the project in Xcode

Open the `.xcodeproj` file in Xcode. Build and run the project by selecting your target device and clicking the Run button.

## Usage

After launching the app, follow the on-screen instructions to capture text using your device's camera. The app will extract and display the text, with options to read it out loud using the text-to-speech feature.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Google Vision API for providing the text extraction capabilities.

