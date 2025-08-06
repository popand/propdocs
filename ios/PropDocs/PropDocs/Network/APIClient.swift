//
//  APIClient.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation

// MARK: - API Endpoint

struct APIEndpoint {
    let path: String
    let method: HTTPMethod = .GET
    
    init(path: String) {
        self.path = path
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - API Error

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(String)
    case unauthorized
    case forbidden
    case notFound
    case unknown(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Forbidden access"
        case .notFound:
            return "Resource not found"
        case .unknown(let code):
            return "Unknown error with code: \(code)"
        }
    }
}

// MARK: - API Client

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: URL
    private let session: URLSession
    private let keychainManager = KeychainManager.shared
    
    private init() {
        // TODO: Configure with actual API base URL
        self.baseURL = URL(string: "https://api.propdocs.com/v1")!
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - GET Requests
    
    func get<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        requiresAuth: Bool = false
    ) async throws -> T {
        let request = try buildRequest(for: endpoint, method: .GET, requiresAuth: requiresAuth)
        return try await performRequest(request, responseType: responseType)
    }
    
    // MARK: - POST Requests
    
    func post<T: Codable, U: Codable>(
        endpoint: APIEndpoint,
        body: T,
        responseType: U.Type,
        requiresAuth: Bool = false
    ) async throws -> U {
        let request = try buildRequest(for: endpoint, method: .POST, body: body, requiresAuth: requiresAuth)
        return try await performRequest(request, responseType: responseType)
    }
    
    func post<T: Codable>(
        endpoint: APIEndpoint,
        body: T,
        responseType: EmptyResponse.Type,
        requiresAuth: Bool = false
    ) async throws -> EmptyResponse {
        let request = try buildRequest(for: endpoint, method: .POST, body: body, requiresAuth: requiresAuth)
        let _ = try await performDataRequest(request)
        return EmptyResponse()
    }
    
    // MARK: - PUT Requests
    
    func put<T: Codable, U: Codable>(
        endpoint: APIEndpoint,
        body: T,
        responseType: U.Type,
        requiresAuth: Bool = true
    ) async throws -> U {
        let request = try buildRequest(for: endpoint, method: .PUT, body: body, requiresAuth: requiresAuth)
        return try await performRequest(request, responseType: responseType)
    }
    
    // MARK: - DELETE Requests
    
    func delete(
        endpoint: APIEndpoint,
        requiresAuth: Bool = true
    ) async throws {
        let request = try buildRequest(for: endpoint, method: .DELETE, requiresAuth: requiresAuth)
        let _ = try await performDataRequest(request)
    }
    
    // MARK: - Private Methods
    
    private func buildRequest<T: Codable>(
        for endpoint: APIEndpoint,
        method: HTTPMethod,
        body: T? = nil,
        requiresAuth: Bool = false
    ) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication header if required
        if requiresAuth {
            guard let accessToken = keychainManager.accessToken else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if provided
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.networkError(error)
            }
        }
        
        return request
    }
    
    private func buildRequest(
        for endpoint: APIEndpoint,
        method: HTTPMethod,
        requiresAuth: Bool = false
    ) throws -> URLRequest {
        return try buildRequest(for: endpoint, method: method, body: Optional<EmptyRequest>.none, requiresAuth: requiresAuth)
    }
    
    private func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        let data = try await performDataRequest(request)
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(responseType, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    private func performDataRequest(_ request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(URLError(.badServerResponse))
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            case 400...499, 500...599:
                // Try to decode error message from response
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.message)
                } else {
                    throw APIError.unknown(httpResponse.statusCode)
                }
            default:
                throw APIError.unknown(httpResponse.statusCode)
            }
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
    }
}

// MARK: - Helper Types

struct EmptyRequest: Codable {}

struct EmptyResponse: Codable {}

struct APIErrorResponse: Codable {
    let message: String
    let code: String?
}