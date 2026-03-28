//
//  Exercise.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import Foundation

// Exercise Model
struct Exercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let muscle: String
    let equipment: String
    let difficulty: String
    let instructions: String

    var isFavorite: Bool = false


    enum CodingKeys: String, CodingKey {
        case name, type, muscle, equipment, difficulty, instructions
    }
}

// Exercise Service
class ExerciseService {
    private let apiKey = "Z9kPsS4DodbYXE8uaM5F5A==qM4lRh5wV3bv1oJC"
    private let baseURL = "https://api.api-ninjas.com/v1/exercises"

    func fetchExercises(muscle: String? = nil, name: String? = nil) async throws -> [Exercise] {
        var urlComponents = URLComponents(string: baseURL)
        var queryItems: [URLQueryItem] = []

        if let muscle = muscle, !muscle.isEmpty {
            queryItems.append(URLQueryItem(name: "muscle", value: muscle))
        }

        if let name = name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Exercise].self, from: data)
    }
}
