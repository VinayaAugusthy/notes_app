# Notes App

A Flutter application for managing personal notes with Firebase Authentication and Firestore database. Users can create, edit, delete, and search their notes securely.

## Table of Contents

- [Features](#features)
- [Project Setup](#project-setup)
- [How to Run Locally](#how-to-run-locally)
- [Architecture](#architecture)
- [Database Schema](#database-schema)
- [Authentication Approach](#authentication-approach)
- [Assumptions & Trade-offs](#assumptions--trade-offs)

## Features

- **User Authentication**: Email/password signup and signin with Firebase Auth
- **Persistent Login**: Session persists across app restarts
- **CRUD Operations**: Create, Read, Update, and Delete notes
- **Client-side Search**: Real-time search by note title
- **User Isolation**: Each user can only access their own notes
- **Confirmation Dialogs**: Delete and logout confirmations
- **Error Handling**: Comprehensive error messages and user feedback

## Project Setup

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Firebase account
- Android Studio / VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Firebase Setup

#### Option 1: Using FlutterFire CLI (Recommended)

1. **Install FlutterFire CLI**

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase**

   ```bash
   flutterfire configure
   ```

   - Select your Firebase project
   - Choose platforms (Android, iOS, etc.)
   - The CLI will automatically:
     - Download `google-services.json` for Android
     - Generate `lib/firebase_options.dart`
     - Configure all necessary files

3. **Enable Authentication**

   - In Firebase Console, go to Authentication → Sign-in method
   - Enable "Email/Password" provider

4. **Configure Firestore Database**

   - Go to Firestore Database → Create database
   - Start in production mode.
   - Set location.

5. **Set Firestore Security Rules**

   ```javascript
   rules_version = '2';
   service cloud.firestore {
   match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && userId == request.auth.uid;
    }

    match /notes/{noteId} {

      allow read: if isOwner(resource.data.user_id);

      allow create: if isOwner(request.resource.data.user_id)
        && request.resource.data.title is string
        && request.resource.data.content is string
        && request.resource.data.created_at is timestamp
        && request.resource.data.updated_at is timestamp;

      allow update: if isOwner(resource.data.user_id)
        && request.resource.data.user_id == resource.data.user_id
        && request.resource.data.created_at == resource.data.created_at
        && request.resource.data.updated_at is timestamp;

      allow delete: if isOwner(resource.data.user_id);
    }
   }
   }

   ```

6. **Create Composite Index**

   The composite index is required for querying notes by `user_id` and ordering by `updated_at`.

   **Method 1: Using the Error Link (Easiest)**

   - Run the app and navigate to the notes view
   - When the query executes, Firestore will return an error with a link
   - Click the link in the error message
   - It will open Firestore Console with the index pre-configured
   - Click "Create Index"
   - Wait for the index to build (usually takes a few minutes)

   **Method 2: Manual Creation**

   - Firestore Console → Indexes → Create Index
   - Collection ID: `notes`
   - Fields to index:
     - `user_id` (Ascending)
     - `updated_at` (Descending)
   - Click "Create Index"

#### Option 2: Manual Setup (Alternative)

If you prefer manual setup instead of CLI:

1. **Create a Firebase Project**

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use an existing one

2. **Add Android App to Firebase**

   - In Firebase Console, click "Add app" → Select Android
   - Package name: `com.example.notes_app`
   - Download `google-services.json`
   - Place it in `android/app/` directory

3. **Generate Firebase Options**

   - Use FlutterFire CLI: `flutterfire configure`
   - Or manually create `lib/firebase_options.dart` with your Firebase config

4. **Follow steps 3-6 from Option 1** (Enable Auth, Configure Firestore, Set Rules, Create Index)

### Install Dependencies

```bash
flutter pub get
```

## How to Run Locally

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd notes_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Verify Firebase configuration**

   - Ensure `android/app/google-services.json` exists
   - Ensure `lib/firebase_options.dart` exists

4. **Run the app**

   ```bash
   flutter run
   ```

## Architecture

### Architectural Pattern: MVVM (Model-View-ViewModel)

The app follows the **MVVM (Model-View-ViewModel)** architectural pattern with clean architecture principles, using **Riverpod** for state management.

### Architecture Layer Details

#### 1. **Presentation Layer** (`lib/presentation/`)

**Views (UI)**

- `auth/`: Login, Signup, AuthWrapper
- `notes/`: NotesView, AddEditNotesView
- `widgets/`: Reusable UI components

**ViewModels (Business Logic)**

- `auth/auth_view_model.dart`: Handles authentication logic
- `notes/notes_view_model.dart`: Handles notes CRUD operations and search

**Responsibilities:**

- UI rendering and user interactions
- Delegates business logic to ViewModels
- Observes ViewModel state changes via Riverpod

#### 2. **Domain Layer** (`lib/domain/`)

**Models**

- `note_model.dart`: Note data structure with Firestore serialization

**Responsibilities:**

- Defines business entities
- Data transformation (toMap/fromMap)
- No dependencies on external frameworks

#### 3. **Core Layer** (`lib/core/`)

**Constants**

- `app_colors.dart`: Centralized color definitions
- `app_strings.dart`: All UI text strings

**Utils**

- `app_snackbar.dart`: Reusable snackbar utility

**Extensions**

- `media_query_extensions.dart`: Helper extensions for responsive design

**Responsibilities:**

- Shared utilities and constants
- Reusable helper functions
- App-wide configurations

### State Management: Riverpod

**Pattern**: ChangeNotifier with Riverpod Provider

**Providers:**

- `authProvider`: Manages authentication state
- `notesProvider`: Manages notes data and search state

## Database Schema

### Firestore Collection: `notes`

Each document in the `notes` collection represents a single note.

#### Document Structure

```javascript
{
  "title": string,
  "content": string,
  "user_id": string,
  "created_at": timestamp,
  "updated_at": timestamp
}
```

#### Document ID

- Auto-generated by Firestore when creating a new note
- Used as the unique identifier for each note

#### Indexes

**Composite Index Required:**

- Collection: `notes`
- Fields:
  - `user_id` (Ascending)
  - `updated_at` (Descending)

This index is required for the query that fetches all notes for a user, ordered by most recently updated.

## Authentication Approach

### Method: Firebase Authentication (Email/Password)

The app uses **Firebase Authentication** with email and password as the authentication method.

### Implementation Details

1. **Sign Up**

   - User provides email and password
   - Password confirmation is validated on client-side
   - Firebase creates a new user account
   - User is automatically signed in after successful signup

2. **Sign In**

   - User provides email and password
   - Firebase validates credentials
   - On success, user session is established

3. **Session Persistence**

   - Firebase Auth automatically persists user sessions
   - `AuthWrapper` widget checks authentication state on app start
   - If user is authenticated, navigates to `NotesView`
   - If not authenticated, shows `LoginView`

4. **Sign Out**
   - User can logout from the notes view
   - Confirmation dialog prevents accidental logout
   - Session is cleared from Firebase Auth

### Security Features

- **User Isolation**: Each user can only access notes where `user_id` matches their Firebase Auth UID
- **Firestore Security Rules**: Enforce data access at database level
- **Client-side Validation**: Form validation before API calls
- **Error Handling**: User-friendly error messages for authentication failures

## Assumptions & Trade-offs

### Assumptions

1. **User Base**: Assumes users will have a reasonable number of notes (< 1000 per user)

   - Client-side search works efficiently for this scale
   - All notes are fetched once and filtered locally

2. **Network**: Assumes users have internet connectivity for initial authentication and data sync

   - Offline support is limited (works after initial fetch)

3. **Platform**: Primarily designed for Android (iOS support may need additional configuration)

## Notes

- The app requires an active internet connection for authentication and initial data fetch
- Search functionality works offline after initial data load
- Composite index must be created in Firestore Console for the app to work correctly
