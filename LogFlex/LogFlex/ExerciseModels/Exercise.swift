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
