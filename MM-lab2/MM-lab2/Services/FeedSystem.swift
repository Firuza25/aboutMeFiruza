//
//  FeedSystem.swift
//  MM-lab2
//
//  Created by Firuza on 28.02.2025.
//

import Foundation
import UIKit

class FeedSystem {
    private var userCache: [String: UserProfile] = [:] // Dictionary
    private var feedPosts: [Post] = [] // Ordered list of posts
    private var hashtags: Set<String> = [] // Unique, fast lookup

    func addPost(_ post: Post) {
        feedPosts.insert(post, at: 0) // Insert a new one at the beginning
        userCache[post.author.id] = post.author
        hashtags.formUnion(post.hashtags)
    }

    func removePost(_ post: Post) {
        if let index = feedPosts.firstIndex(of: post) {
            feedPosts.remove(at: index)
        }
    }

    func getPosts() -> [Post] {
        return feedPosts
    }
}
