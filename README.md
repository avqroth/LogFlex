# LogFlex

A native iOS fitness tracking app built with Swift and SwiftUI.

## Features
- Heart rate, steps, and calorie tracking via HealthKit integration
- Water intake logging
- Exercise library with the ability to favorite exercises
- Custom workout builder organized by activity type
- Calendar view displaying full workout history by activity

## Tech Stack
- Swift / SwiftUI
- HealthKit (heart rate, steps, calories)
- Core Data (local persistence for workouts, exercises, water logs)
- MVVM architecture
- EventKit / custom calendar UI

## Current Bugs
- Exercise Library network connection

## Screenshots
[Add screenshots here]

## Requirements
- iOS 16.0+
- Xcode 15+
- iPhone with HealthKit support

 
 ## API Key Setup
This project reads the API key from Xcode Build Settings via `$(API_NINJA_KEY)`.
To run locally, add `API_NINJA_KEY` as a User-Defined Setting in Build Settings
with your API-Ninjas key as the value.

## Security Note
The API key is injected at build time and never stored in source code or git history.
In production this would be replaced with a backend proxy.
