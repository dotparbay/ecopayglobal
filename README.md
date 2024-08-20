Here’s a step-by-step guide for setting up your Flutter development environment and running a cloned Flutter project using Visual Studio Code:

### 1. **Install Flutter SDK**

1. **Download and Install Flutter SDK:**
   - Visit the [Flutter download page](https://flutter.dev/docs/get-started/install).
   - Download the Flutter SDK for your operating system.
   - Extract the downloaded file and move it to an appropriate directory, e.g., `~/development/flutter`.

2. **Set Up Environment Variables:**
   - Add the `flutter/bin` directory to your system’s PATH environment variable.
   - **macOS/Linux:**
     ```bash
     export PATH="$PATH:<flutter-sdk-directory>/bin"
     ```
     Add this line to your `.bashrc`, `.zshrc`, or other shell configuration file.
   - **Windows:**
     - Open "Edit the system environment variables."
     - Click on the "Environment Variables" button.
     - Edit the "Path" variable and add the path to the `flutter/bin` directory.

3. **Check Flutter Dependencies:**
   - Open a terminal or command prompt.
   - Run the following command to check if Flutter is installed correctly:
     ```bash
     flutter doctor
     ```
   - Follow any instructions provided to install missing dependencies.

### 2. **Install Visual Studio Code**

1. **Download and Install Visual Studio Code:**
   - Visit the [Visual Studio Code download page](https://code.visualstudio.com/).
   - Download and install the version appropriate for your operating system.

2. **Install Flutter and Dart Extensions:**
   - Open Visual Studio Code.
   - Go to the Extensions view by clicking the square icon on the sidebar or pressing `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (macOS).
   - Search for "Flutter" and install the Flutter extension. The Dart extension will be installed automatically as a dependency.

3. **Configure VS Code:**
   - With the Flutter extension installed, you can now create and manage Flutter projects within VS Code.

### 3. **Set Up Android and iOS Development Environments**

1. **Set Up Android Development Environment:**
   - **Install Android Studio:**
     - Download and install Android Studio from the [Android Studio website](https://developer.android.com/studio).
   - **Install Android SDK:**
     - Open Android Studio and install the necessary SDK and emulator components.
   - **Set Up an Emulator:**
     - In Android Studio, open the "AVD Manager" and create a new virtual device.

2. **Set Up iOS Development Environment (macOS only):**
   - **Install Xcode:**
     - Download Xcode from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835).
   - **Install Xcode Command Line Tools:**
     - Open Xcode and go to "Preferences" > "Locations" and select the appropriate Command Line Tools version.

### 4. **Clone and Run a Flutter Project Using Visual Studio Code**

1. **Clone the Flutter Project:**
   - Open Visual Studio Code.
   - Open the Command Palette by pressing `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS).
   - Type `Git: Clone` and select it.
   - Enter the Git repository URL(https://github.com/dotparbay/ecopayglobal) for the Flutter project you want to clone.
   - Choose a local directory where you want to clone the repository.

2. **Open the Cloned Project:**
   - Once the cloning process is complete, VS Code will prompt you to open the cloned repository.
   - Click "Open" to load the project in VS Code.

3. **Install Project Dependencies:**
   - Open a new terminal in VS Code by selecting `Terminal > New Terminal`.
   - Navigate to the project directory if needed:
     ```bash
     cd <your-cloned-repo-directory>
     ```
   - Run the following command to fetch the project dependencies:
     ```bash
     flutter pub get
     ```

4. **Run Build Commands:**
   - In the terminal, run the following commands to set up and build the project:
     ```bash
     flutter pub run build_runner build
     flutter pub run flutter_native_splash:create
     flutter pub run flutter_launcher_icons
     ```

5. **Run the Flutter Project:**
   - Ensure a connected device or emulator is available.
   - In the terminal, run the Flutter project with:
     ```bash
     flutter run
     ```
   - If you encounter errors during the application startup, it may be due to an existing version of the app already installed on your device or emulator. Please follow the steps below to remove the previous version of the app:

     **Removing the Previous Version of the App:**

     - **On Android Device/Emulator:**
       1. Go to `Settings` on your Android device or emulator.
       2. Navigate to `Apps` or `Application Manager`.
       3. Find the app by its name.
       4. Select the app and tap `Uninstall`.

     - **On iOS Device/Simulator:**
       1. Find the app on your iOS device or simulator.
       2. Tap and hold the app icon until it starts wiggling.
       3. Tap the `X` icon that appears on the app to delete it.
       4. Confirm the deletion by tapping `Delete`.

     After removing the previous version of the app, run `flutter run` again to launch the updated application.

---
