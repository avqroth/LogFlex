//
//  NetworkError.swift
//  LogFlex
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case badResponse(statusCode: Int)
    case decodingFailed(reason: String)
    case noInternet
    case timeout
    case serverError(message: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .badResponse(let code):
            return code == 404
                ? "No exercises found"
                : "Server returned error \(code)"
        case .decodingFailed(let reason):
            return "Could not process data: \(reason)"
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
