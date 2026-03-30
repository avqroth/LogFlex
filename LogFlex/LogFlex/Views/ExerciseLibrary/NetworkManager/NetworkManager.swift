//
//  NetworkManager.swift
//  LogFlex
//

import SwiftUI
import Foundation

@MainActor
class NetworkManager: ObservableObject {
    @Published var isLoading = false
    @Published var error: NetworkError?

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // ✅ Original URL-only method kept for simple calls
    func fetchData<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return try await fetchData(request: URLRequest(url: url))
    }

    // ✅ New method — accepts full URLRequest with headers, auth, etc.
    func fetchData<T: Decodable>(request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as NSError {
            switch error.code {
            case NSURLErrorNotConnectedToInternet: throw NetworkError.noInternet
            case NSURLErrorTimedOut:               throw NetworkError.timeout
            case NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost:    throw NetworkError.invalidURL
            default:                               throw NetworkError.unknown
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse(statusCode: httpResponse.statusCode)
        }

        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 [\(request.url?.lastPathComponent ?? "unknown")] Raw JSON:\n\(jsonString)")
        }
        #endif

        do {
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Missing key '\(key.stringValue)' at: \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            throw NetworkError.decodingFailed(reason: "Missing field: '\(key.stringValue)'")
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Type mismatch — expected \(type) at: \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            throw NetworkError.decodingFailed(reason: "Type mismatch at '\(context.codingPath.last?.stringValue ?? "unknown")'")
        } catch let DecodingError.valueNotFound(type, context) {
            print("❌ Null value — expected \(type) at: \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            throw NetworkError.decodingFailed(reason: "Null value for '\(context.codingPath.last?.stringValue ?? "unknown")'")
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Data corrupted: \(context.debugDescription)")
            throw NetworkError.decodingFailed(reason: "Corrupted data — likely not valid JSON")
        } catch {
            throw NetworkError.decodingFailed(reason: error.localizedDescription)
        }
    }
}
