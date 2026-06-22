# VoxFable 📖✨

VoxFable is an AI-powered Interactive Story Buddy & Quiz mobile application built with Flutter, designed for children aged 6–10. The app blends rich audio narration, real-time word-by-word visual highlighting, and a responsive animated mascot to create an engaging, gamified learning experience.

---

## 📸 Screenshots & Demo

| Story Screen | Quiz Screen | Victory Screen |
| :---: | :---: | :---: |
| _[Placeholder for Story Screen]_ | _[Placeholder for Quiz Screen]_ | _[Placeholder for Victory Screen]_ |

### 🎥 Demo Video
Watch the full walkthrough of VoxFable in action: **[Link to Demo Video]**

---

## 🌟 Core Features

### 1. Interactive AI Story Narration
* **ElevenLabs TTS Integration**: Converts text into premium, child-friendly voice narration using ElevenLabs Text-to-Speech.
* **Synchronized Highlighting**: Tracks audio timestamps to highlight words in real-time as they are spoken, assisting with reading comprehension.
* **Locked vertical pagination**: Programmatic-only vertical scrolling between the storybook and quiz to maintain learning flow.

### 2. Responsive Animated Mascot (Peblo)
* **Idle State**: Floating motion with periodic natural blinking.
* **Thinking State**: Floating motion with eyes looking up, glowing yellow.
* **Reading State**: Looks down at the book with eyes scanning horizontally to simulate reading progress.
* **Celebration State**: Mascot jumps in excitement with smiling green eyes upon correct answers and story completion.
* **Disappointment State**: Mascot droops with red cross-eyes (`X X`) on incorrect answers, accompanied by haptic device vibration.

### 3. Gamified Quiz Card Swiper
* **Tinder-Style Stack**: Built on top of `flutter_card_swiper`, stacking question cards with visual depth (background cards peek out).
* **Auto-Swipe on Correct Answer**: Manual gestures are disabled. Once the child selects the correct option, the button turns purple with a green checkmark and automatically swipes left after a 2-second delay.
* **Incorrect Selection Feedback**: Highlights only the tapped incorrect choice in red/pink with a red cross (without revealing the correct answer), plays haptic feedback, and shakes the card horizontally before allowing a retry.
* **Dynamic Sizing**: Button sizes (padding, badge, and font size) automatically scale based on the number of options, spacing evenly to fill the card's available height.
* **Playful Badges**: Options feature colorful circular badges styled with animal emojis (🦊, 🐻, 🐢, 🐹) for a child-friendly visual aesthetic.

### 4. Interactive Parallax Background
* Custom starry sky gradient background for the quiz screen with layered hills, clouds, and stars scrolling/moving dynamically in response to scroll positioning.

---

## 📂 Project Structure

```directory
voxfable/
├── assets/
│   ├── data/                 # JSON file containing mock story and quiz content
│   ├── fonts/                # Poppins font files (Light, Regular, Medium, Bold, Black)
│   ├── images/               # WebP images for parallax background layers
│   └── logo/                 # Application branding logo files
├── lib/
│   ├── core/
│   │   ├── audio/            # Audio caching and management services
│   │   └── network/          # API services (e.g., ElevenLabs TTS service)
│   ├── feature/
│   │   └── story/
│   │       ├── data/
│   │       │   ├── models/   # StoryContent and QuizQuestion data models
│   │       │   └── repos/    # StoryState data model representing current screen states
│   │       ├── view/
│   │       │   ├── screens/  # Page-level screens (StoryScreen, VictoryScreen)
│   │       │   └── widgets/  # UI Widgets (OptionCard, PebloMascot, QuizView, etc.)
│   │       └── view_model/   # StoryViewModel state management using Riverpod
│   └── main.dart             # Application entry point
├── pubspec.yaml              # App dependencies and assets configuration
└── README.md                 # Project documentation
```

---

## 🛠️ Architecture & Tech Stack

* **Framework**: Flutter (Dart SDK `^3.12.1`)
* **State Management**: Riverpod (`flutter_riverpod` & `riverpod_generator` with code generation)
* **Audio Playback**: `audioplayers`
* **Card Animations**: `flutter_card_swiper`
* **Transitions**: `flutter_animate` & custom Rive-inspired canvas painting
* **Networking**: `dio` (with robust API error validation)

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (Version `>=3.12.1`)
* ElevenLabs API Key

### Installation

1. **Clone the Repository**:
   ```bash
   git clone <repository_url>
   cd voxfable
   ```

2. **Retrieve Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**:
   Create a `.env` file in the root directory and add your ElevenLabs credentials:
   ```env
   ELEVEN_LABS_API_KEY=your_elevenlabs_api_key_here
   ```

4. **Run Code Generation**:
   Generate Riverpod providers:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests & Diagnostics

To execute static analysis:
```bash
flutter analyze
```

To run the widget and unit test suites:
```bash
flutter test
```
