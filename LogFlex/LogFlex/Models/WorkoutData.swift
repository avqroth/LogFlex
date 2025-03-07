//
//  CustomWorkoutModel.swift
//  LogFlex
//
//  Created by Avery Roth on 1/17/25.
//

import Foundation
import SwiftData

@Model
final class WorkoutLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var name: String
    var activityType: ActivityType
    @Relationship(deleteRule: .cascade) var activities: [ActivityData]
    @Relationship(deleteRule: .cascade) var exercises: [ExerciseLog]
    var distance: Double?
    var duration: Double?
    var laps: Int?
    var pace: Double?
    var averageHeartRate: Int?

    init(id: UUID = UUID(),
         date: Date,
         name: String,
         activityType: ActivityType,
         activities: [ActivityData] = [],
         exercises: [ExerciseLog] = [],
         distance: Double? = nil,
         duration: Double? = nil,
         laps: Int? = nil,
         pace: Double? = nil,
         averageHeartRate: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.activityType = activityType
        self.activities = activities
        self.exercises = exercises
        self.distance = distance
        self.duration = duration
        self.laps = laps
        self.pace = pace
        self.averageHeartRate = averageHeartRate
    }
}

@Model
final class ActivityData {
    @Attribute(.unique) var id: UUID
    var type: ActivityType
    @Relationship(deleteRule: .cascade) var exercises: [ExerciseLog]
    @Relationship(deleteRule: .cascade) var metrics: ActivityMetrics

    init(id: UUID = UUID(), type: ActivityType, exercises: [ExerciseLog] = [], metrics: ActivityMetrics) {
        self.id = id
        self.type = type
        self.exercises = exercises
        self.metrics = metrics
    }
}

@Model
final class ExerciseLog {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var metrics: ActivityMetrics

    init(id: UUID = UUID(), name: String, metrics: ActivityMetrics) {
        self.id = id
        self.name = name
        self.metrics = metrics
    }
}

@Model
final class ActivityMetrics {
    @Attribute(.unique) var id: UUID
    var distance: String
    var duration: String
    var laps: String
    var calories: String
    var sets: String
    var reps: String
    var weight: String

    init(id: UUID = UUID(),
         distance: String = "",
         duration: String = "",
         laps: String = "",
         calories: String = "",
         sets: String = "",
         reps: String = "",
         weight: String = "") {
        self.id = id
        self.distance = distance
        self.duration = duration
        self.laps = laps
        self.calories = calories
        self.sets = sets
        self.reps = reps
        self.weight = weight
    }
}

class ActivitySection: Identifiable {
    let id = UUID()
    var type: ActivityType
    var exercises: [ExerciseLog]
    var metrics: ActivityMetrics

    init(type: ActivityType, exercises: [ExerciseLog] = [], metrics: ActivityMetrics = ActivityMetrics()) {
        self.type = type
        self.exercises = exercises
        self.metrics = metrics
    }
}

enum ActivityType: String, Codable, CaseIterable{
    case strength = "Strength Training"
    case running = "Running"
    case walking = "Walking"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case yoga = "Yoga"
    case hiit = "HIIT"
    case sports = "Sports"
    case other = "Other"

    var icon: String {
            switch self {
            case .strength:
                return "dumbbell.fill"
            case .running:
                return "figure.run"
            case .walking:
                return "figure.walk"
            case .cycling:
                return "bicycle"
            case .swimming:
                return "figure.pool.swim"
            case .yoga:
                return "figure.mind.and.body"
            case .hiit:
                return "heart.circle.fill"
            case .sports:
                return "sportscourt.fill"
            case .other:
                return "figure.mixed.cardio"
            }
        }

}
