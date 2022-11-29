//
//  FeaturedFeedViewModel.swift
//  ReclipFeaturedFeed
//

import Foundation
import Combine

final class FeaturedFeedViewModel: ObservableObject {
    let apiService: APIServiceProtocol
    @Published private(set) var items: [FeedItem] = []

    init(apiService: APIServiceProtocol = APIService(jsonDecoder: FeaturedFeedAPI.jsonDecoder)) {
        self.apiService = apiService
    }
}

extension FeaturedFeedViewModel {
    func fetchVideos() {
        self.apiService.fetchFeatured { [weak self] result in
            switch result {
            case .success(let items):
                self?.items = items
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
