//
//  FeedVideo.swift
//  ReclipFeaturedFeed
//

import Foundation

struct FeedItem: Codable{
    let id: String
    let video: Video
    let createdBy: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdBy
        case createdAt
        case video = "share"
    }
}

struct Video: Codable {
    let id: String
    let code: String
    let reclipId: String
    let userId: String
    let username: String
    let videoTitle: String
    let videoFilename: String
    let videoUrl: String
    let videoUrlHls: String?
    let url: String
    let createdAt: Date
    let endedAt: Date?
    let disabled: Bool
}
