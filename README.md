1. Executive Summary
The goal of this assignment was to transition the application from a local-only tool to a cloud-enabled service. By integrating Firebase Realtime Database and Firebase Auth, users can now save their favorite cities and custom notes to a persistent cloud store. This data is synchronized across sessions and is isolated to each specific user through anonymous authentication.

2. System Architecture & Data Model
2.1 Database Structure (JSON)

The data is stored in a hierarchical structure within the Firebase Realtime Database. Each user has a unique node identified by their uid to ensure data privacy and organization.

Example JSON Entry:

JSON
{
  "favorites": {
    "USER_UNIQUE_ID": {
      "-OJh7x9abc123": {
        "cityName": "New York",
        "note": "Great for winter vacations",
        "createdAt": 1707345600000,
        "id": "-OJh7x9abc123",
        "createdBy": "USER_UNIQUE_ID"
      }
    }
  }
}
2.2 Model Definition

The FavoriteCity struct was updated to conform to Codable and Identifiable, allowing seamless translation between Swift objects and Firebase dictionaries.

3. Key Features Implementation
3.1 Anonymous Authentication

To meet the requirement of per-user data isolation without requiring a complex registration flow, Firebase Anonymous Auth was implemented. Upon launching the app, the FirebaseManager requests a unique ID from Firebase.

Benefit: Provides a personalized experience and secures data via rules.

Logic: Data is only saved once the userId is successfully retrieved.

3.2 Real-time CRUD Operations

The application supports the full lifecycle of data:

Create: Users can search for a city and save it to the cloud with a custom note.

Read: The app uses a Firebase .value observer, ensuring the UI updates instantly if data changes on the server.

Update: A formal Edit Mode was added. Users click a Pencil icon to turn the static note into a TextField, allowing cloud updates via updateChildValues.

Delete: A swipe or button tap triggers removeValue() to delete entries from the cloud.

3.3 API Layer Reuse (Weather Integration)

A significant requirement was the reuse of the Assignment 7 weather logic. The FirebaseManager iterates through cloud favorites and uses the WeatherManager to fetch live temperatures for each saved city.
