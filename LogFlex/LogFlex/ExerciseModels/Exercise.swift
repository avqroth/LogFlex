//
//  Exercise.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import Foundation

struct Exercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let muscle: String
    let equipment: String?
    let difficulty: String
    let instructions: String

    var isFavorite: Bool = false


    enum CodingKeys: String, CodingKey {
        case name, type, muscle, equipment, difficulty, instructions
    }
}

class ExerciseService {
    private let apiKey = SecretsManager.apiNinjaKey
    private let baseURL = "https://api.api-ninjas.com/v1/exercises"
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    static let mockExercises: [Exercise] = [
        Exercise(name: "Barbell Bench Press", type: "strength", muscle: "chest",
                 equipment: "barbell", difficulty: "intermediate",
                 instructions: "Lie on a flat bench and grip the barbell slightly wider than shoulder width. Lower the bar to your chest then press back up to the starting position."),
        Exercise(name: "Push-Up", type: "strength", muscle: "chest",
                 equipment: nil, difficulty: "beginner",
                 instructions: "Start in a plank position with hands slightly wider than shoulder width. Lower your chest to the floor then push back up."),
        Exercise(name: "Incline Dumbbell Press", type: "strength", muscle: "chest",
                 equipment: "dumbbell", difficulty: "intermediate",
                 instructions: "Set a bench to a 45 degree incline. Press the dumbbells up from chest height until arms are fully extended then lower slowly."),
        Exercise(name: "Bicep Curl", type: "strength", muscle: "biceps",
                 equipment: "dumbbell", difficulty: "beginner",
                 instructions: "Stand holding dumbbells at your sides with palms facing forward. Curl the weights up to your shoulders then lower with control."),
        Exercise(name: "Hammer Curl", type: "strength", muscle: "biceps",
                 equipment: "dumbbell", difficulty: "beginner",
                 instructions: "Hold dumbbells with a neutral grip, palms facing each other. Curl the weights toward your shoulders without rotating your wrists."),
        Exercise(name: "Pull-Up", type: "strength", muscle: "lats",
                 equipment: nil, difficulty: "intermediate",
                 instructions: "Hang from a bar with palms facing away and hands shoulder width apart. Pull yourself up until your chin clears the bar then lower slowly."),
        Exercise(name: "Lat Pulldown", type: "strength", muscle: "lats",
                 equipment: "cable", difficulty: "beginner",
                 instructions: "Grip the bar slightly wider than shoulder width. Pull the bar down to your upper chest while keeping your torso upright then return slowly."),
        Exercise(name: "Squat", type: "strength", muscle: "quadriceps",
                 equipment: "barbell", difficulty: "intermediate",
                 instructions: "Stand with feet shoulder width apart and bar across your upper back. Lower until thighs are parallel to the floor then drive back up."),
        Exercise(name: "Leg Press", type: "strength", muscle: "quadriceps",
                 equipment: "machine", difficulty: "beginner",
                 instructions: "Sit in the machine with feet shoulder width apart on the platform. Lower the weight until knees reach 90 degrees then press back up."),
        Exercise(name: "Romanian Deadlift", type: "strength", muscle: "hamstrings",
                 equipment: "barbell", difficulty: "intermediate",
                 instructions: "Hold the bar at hip height with a shoulder width grip. Hinge at the hips and lower the bar down your legs until you feel a stretch in your hamstrings then return."),
        Exercise(name: "Plank", type: "strength", muscle: "abdominals",
                 equipment: nil, difficulty: "beginner",
                 instructions: "Hold a push-up position with your body in a straight line from head to heels. Keep your core braced and hold for the desired duration."),
        Exercise(name: "Cable Crunch", type: "strength", muscle: "abdominals",
                 equipment: "cable", difficulty: "beginner",
                 instructions: "Kneel below a cable machine and hold the rope behind your head. Flex your waist to bring your elbows toward your knees then return slowly.")
    ]

    func fetchExercises(muscle: String? = nil, name: String? = nil) async throws -> [Exercise] {
        var urlComponents = URLComponents(string: baseURL)
        var queryItems: [URLQueryItem] = []

        if let muscle = muscle, !muscle.isEmpty {
            queryItems.append(URLQueryItem(name: "muscle", value: muscle))
        }
        if let name = name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        urlComponents?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        #if DEBUG
        print("🔑 API Key being sent: '\(apiKey)'")
        print("🌐 Request URL: \(url.absoluteString)")
        print("📋 Headers: \(request.allHTTPHeaderFields ?? [:])")
        #endif

        return try await networkManager.fetchData(request: request)
    }
}
