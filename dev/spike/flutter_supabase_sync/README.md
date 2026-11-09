# SP-01 — Flutter SQLite and Supabase Synchronization Spike

## Overview

This spike demonstrates the feasibility of implementing multi-user authentication, local SQLite storage, and cloud synchronization using Flutter and Supabase.

The application allows users to create accounts, sign in, save string entries locally, and synchronize those entries with Supabase. Each user has a separate local SQLite database associated with their account.

The spike was developed to investigate technical risks involving cloud synchronization and user-specific data access for the Rep Rank fitness tracking application.

## Features

- **User Authentication:** Create accounts, sign in, and log out using Supabase Authentication.
- **Local Storage:** Save and retrieve string entries using SQLite.
- **Account Separation:** Each authenticated user has a separate local SQLite database.
- **Cloud Upload:** Press the Finish button to upload unsynchronized entries to Supabase.
- **Cloud Download:** Automatically retrieve and merge cloud entries into local SQLite storage when signing in.
- **Offline Support:** Entries remain stored locally when internet connectivity is unavailable.
- **Duplicate Prevention:** UUIDs identify entries across databases to prevent duplicate records during synchronization.
- **Access Controls:** Supabase Row Level Security (RLS) restricts users to accessing their own cloud records.

## Technologies

- Flutter / Dart
- SQLite (`sqflite` and `sqflite_common_ffi`)
- Supabase Authentication
- Supabase PostgreSQL
- UUID package

## Running the Application

### 1. Prerequisites

Install the following:

- Flutter SDK
- Dart SDK (included with Flutter)
- VS Code or Android Studio
- Windows desktop development tools or an Android emulator (optional)
- Access to a configured Supabase project

### 2. Install Dependencies

Open a terminal in the Flutter project directory containing `pubspec.yaml`.

Run:

```bash
flutter pub get
```

### 3. Configure Supabase

In `lib/main.dart`, locate `Supabase.initialize()` and configure the project URL and publishable key:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  publishableKey: 'YOUR_SUPABASE_PUBLISHABLE_KEY',
);
```

The Supabase project must have a `public.notes` table with the following columns:

| Column | Type |
|---|---|
| id | UUID (Primary Key) |
| user_id | UUID (Foreign Key to auth.users) |
| content | TEXT |
| created_at | TIMESTAMPTZ |

Row Level Security must be enabled, with policies permitting authenticated users to select and insert only records belonging to their own accounts.

### 4. Run the Application

For Windows:

```bash
flutter run -d windows
```

For Android, start an emulator and run:

```bash
flutter devices
flutter run -d <device-id>
```

Replace `<device-id>` with the Android emulator ID returned by `flutter devices`.

## Using the Application

1. Create an account or sign in with an existing account.
2. Enter a string into the text field.
3. Press **Save to SQLite** to store the entry locally.
4. View previously saved entries in the application.
5. Press **Finish (Sync to Supabase)** to upload unsynchronized entries.
6. Log out and sign back in to download cloud entries and merge them with local records.

Entries are associated with the authenticated account and remain available in its local SQLite database.

## Testing and Results

The spike was tested using two separate accounts and Windows and Android execution environments.

Testing included:

- Account creation, login, and logout.
- Separation of locally stored entries between users.
- SQLite-to-Supabase uploads.
- Supabase-to-SQLite downloads.
- Recovery from failed uploads caused by loss of connectivity.
- Prevention of duplicate entries during repeated synchronization.
- RLS SELECT testing to verify users cannot retrieve another account's records.
- RLS INSERT testing to verify users cannot create records belonging to another account.

Both RLS security tests passed. Screen recordings documenting the tests are available in the project's GitHub security-validation issue, Issue 15.



