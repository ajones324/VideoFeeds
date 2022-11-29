//
//  VideoFeedsTests.swift
//  VideoFeedsTests
//
//  Created by Andrew Ikenna Jones on 11/29/22.
//

import XCTest
@testable import VideoFeeds

class VideoFeedsTests: XCTestCase {
    
    var viewModel: FeaturedFeedViewModel!
    var mockAPIService: MockApiService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockApiService()
        viewModel = FeaturedFeedViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func test_fetch_featured_videos() {
        viewModel.fetchVideos()
        XCTAssert(mockAPIService!.isFetchVideoCalled)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension XCTestCase {

  func wait(for duration: TimeInterval) {
    let waitExpectation = expectation(description: "Waiting")

    let when = DispatchTime.now() + duration
    DispatchQueue.main.asyncAfter(deadline: when) {
      waitExpectation.fulfill()
    }

    // We use a buffer here to avoid flakiness with Timer on CI
    waitForExpectations(timeout: duration + 0.5)
  }
}


class MockApiService: APIServiceProtocol {

    var isFetchVideoCalled = false
    
    var completeFeaturedVideos: [FeedItem] = [FeedItem]()
    var completeClosure: ((Result<[FeedItem], Error>) -> Void)!
    
    func fetchFeatured(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        isFetchVideoCalled = true
        completeClosure = completion
    }
    
    func fetchSuccess() {
        completeClosure(.success(completeFeaturedVideos))
    }
    
    func fetchFail(error: Error) {
        completeClosure(.failure(error))
    }
}
