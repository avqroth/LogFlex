//
//  NetworkMonitor.swift
//  LogFlex
//
//  Created by Avery Roth on 5/9/25.
//

import SwiftUI
import Foundation

class NetworkManager: ObservableObject {
    @Published var isLoading = false
    @Published var error: NetworkError?

    func fetchData<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.badResponse(statusCode: httpResponse.statusCode)
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            if let nsError = error as NSError?, nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    throw NetworkError.noInternet
                default:
                    throw NetworkError.unknown
                }
            }
            throw NetworkError.unknown
        }
    }
}
