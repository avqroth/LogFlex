//
//  NetworkErrorOverlay.swift
//  LogFlex
//
//  Created by Avery Roth on 5/9/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case badResponse(statusCode: Int)
    case decodingFailed
    case noInternet
    case timeout
    case serverError(message: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .badResponse(let code):
            return code == 404 ? "No exercises found" : "Server returned error code: \(code)"
        case .decodingFailed:
            return "Could not process exercise data"
        case .noInternet:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "Something went wrong"
        }
    }
}
