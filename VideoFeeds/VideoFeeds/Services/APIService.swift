//
//  APIService.swift
//  ReclipFeaturedFeed
//

import Foundation

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

protocol APIServiceProtocol {
    func fetchFeatured(completion: @escaping (Result<[FeedItem], Error>) -> Void)
}

class APIService: APIServiceProtocol {
    private let httpClient: HttpClient
    private let jsonDecoder: JSONDecoder
    
    enum APIServiceError: Error {
        case invalidUrl
    }

    init(jsonDecoder: JSONDecoder) {
        self.httpClient = HttpClient(session: URLSession.shared)
        self.jsonDecoder = jsonDecoder
    }
    
    func fetchFeatured(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        httpClient.get(url: FeaturedFeedAPI.endpoint) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(HttpClientError.emptyData))
                return
            }
            do {
                let items = try self.jsonDecoder.decode([FeedItem].self, from: data)
                completion(.success(items.unique{$0.video.code == $1.video.code}))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
