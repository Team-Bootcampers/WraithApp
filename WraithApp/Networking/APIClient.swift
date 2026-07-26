//
//  APIClient.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case network(Error)
    case server(statusCode: Int, message: String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz istek adresi."
        case .network:
            return "İnternet bağlantısı sorunu. Lütfen tekrar deneyin."
        case .server(_, let message):
            return message
        case .decoding:
            return "Sunucudan beklenmeyen bir yanıt geldi."
        }
    }
}

/// Thin async/await client for the CoreBackendKit API (https://wraithathon.gokhansal.com).
final class APIClient {

    static let shared = APIClient()

    private let baseURL = URL(string: "https://wraithathon.gokhansal.com")!
    private let session = URLSession.shared

    private init() {}

    func request<Body: Encodable, Response: Decodable>(
        path: String,
        method: String,
        body: Body,
        authToken: String? = nil
    ) async throws -> Response {
        var urlRequest = try makeURLRequest(path: path, method: method, authToken: authToken)
        urlRequest.httpBody = try JSONEncoder().encode(body)
        let data = try await sendRaw(urlRequest)
        return try decode(data)
    }

    func request<Response: Decodable>(
        path: String,
        method: String,
        authToken: String? = nil
    ) async throws -> Response {
        let urlRequest = try makeURLRequest(path: path, method: method, authToken: authToken)
        let data = try await sendRaw(urlRequest)
        return try decode(data)
    }

    func requestNoContent(
        path: String,
        method: String,
        authToken: String? = nil
    ) async throws {
        let urlRequest = try makeURLRequest(path: path, method: method, authToken: authToken)
        _ = try await sendRaw(urlRequest)
    }

    func requestNoContent<Body: Encodable>(
        path: String,
        method: String,
        body: Body,
        authToken: String? = nil
    ) async throws {
        var urlRequest = try makeURLRequest(path: path, method: method, authToken: authToken)
        urlRequest.httpBody = try JSONEncoder().encode(body)
        _ = try await sendRaw(urlRequest)
    }

    private func decode<Response: Decodable>(_ data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func makeURLRequest(path: String, method: String, authToken: String?) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func sendRaw(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else { return data }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = (try? JSONDecoder().decode(APIErrorBody.self, from: data))?.message ?? "Bir hata oluştu (\(httpResponse.statusCode))."
            throw APIError.server(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }
}

private struct APIErrorBody: Decodable {
    let message: String

    enum CodingKeys: String, CodingKey { case message }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let string = try? container.decode(String.self, forKey: .message) {
            message = string
        } else if let list = try? container.decode([String].self, forKey: .message) {
            message = list.joined(separator: "\n")
        } else {
            message = "Bir hata oluştu."
        }
    }
}
