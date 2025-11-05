//
//  APIService.swift
//  Week03ExviewDidLoad
//
//  Created by sothea007 on 3/11/25.
//
import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    func fetchPosts(completion: @escaping (Result<[Posts], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for network error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for valid data
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Check for valid HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            // Decode JSON data
            do {
                let users = try JSONDecoder().decode([Posts].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case decodingError
}
