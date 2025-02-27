//
//  MyProfile.swift
//  MM-lab2
//
//  Created by Firuza on 28.02.2025.
//

import Foundation
import UIKit

protocol ProfileUpdateDelegate {
    // TODO: Consider protocol inheritance requirements
    // Think: When should we restrict protocol to reference types only?
    func profileDidUpdate(_ profile: UserProfile)
    func profileLoadingError(_ error: Error)
}


class MyProfile{
    // TODO: Think about appropriate storage type for active profiles
    private var activeProfiles: [String: UserProfile] = [:]
    
    // TODO: Consider reference type for delegate
    var delegate: ProfileUpdateDelegate?
    
    // TODO: Think about reference management in closure
    var onProfileUpdate: ((UserProfile) -> Void)?
    
    init(delegate: ProfileUpdateDelegate) {
        // TODO: Implement initialization
    }
    
    func loadProfile(id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        // TODO: Implement profile loading
        // Consider: How to avoid retain cycle in completion handler?
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in // Capture self weakly to prevent retain cycle
            guard let self = self else { return }
            
            // Mock profile data
            let profile = UserProfile(id: id, username: "Firuza", bio: "Welcome to my profile, здесь много интересного", profileImageURL: URL(string: "https://i.pinimg.com/236x/d8/b4/b8/d8b4b805b16774a4cc7fccd03aed4c73.jpg"))
            self.activeProfiles[id] = profile
            DispatchQueue.main.async {
                completion(.success(profile))
                self.delegate?.profileDidUpdate(profile)
                self.onProfileUpdate?(profile)
            }
        }
    }
}
