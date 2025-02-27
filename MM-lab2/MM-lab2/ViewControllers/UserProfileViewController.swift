//
//  UserProfileViewController.swift
//  MM-lab2
//
//  Created by Firuza on 28.02.2025.
//

import UIKit

class UserProfileViewController: UIViewController, ProfileUpdateDelegate, ImageLoaderDelegate {

    var profileManager: MyProfile?
    var imageLoader: ImageLoader?

    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let bioLabel = UILabel()

    var isViewingOwnProfile: Bool = false
    var userProfile: UserProfile? {
        didSet { userProfile.map(updateProfile) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProfileManager()
        loadUserProfile()
        
        if isViewingOwnProfile {
            print("No profile")
        } else {
            userProfile.map(updateProfile)
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bioLabel.font = .systemFont(ofSize: 16)
        bioLabel.numberOfLines = 0
        bioLabel.translatesAutoresizingMaskIntoConstraints = false

        [profileImageView, nameLabel, bioLabel].forEach(view.addSubview)

        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            bioLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bioLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupProfileManager() {
        profileManager = MyProfile(delegate: self)
        profileManager?.onProfileUpdate = { [weak self] profile in
            self?.updateProfile(profile)
        }
    }

    private func loadUserProfile() {
        guard userProfile == nil else { return }

        profileManager?.loadProfile(id: "user_123") { [weak self] result in
            if case .success(let profile) = result {
                self?.userProfile = profile
            }
        }
    }

    private func updateProfile(_ profile: UserProfile) {
        nameLabel.text = profile.username
        bioLabel.text = profile.bio

        if let url = profile.profileImageURL {
            imageLoader = ImageLoader()
            imageLoader?.delegate = self
            imageLoader?.completionHandler = { [weak self] image in
                self?.profileImageView.image = image ?? UIImage(systemName: "person.crop.circle")
            }
            imageLoader?.loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }
}

extension UserProfileViewController {
    func profileDidUpdate(_ profile: UserProfile) {
        print("Profile updated: \(profile.username)")
    }

    func profileLoadingError(_ error: Error) {
        print("Failed to load profile: \(error.localizedDescription)")
    }

    func imageLoader(_ loader: ImageLoader, didLoad image: UIImage) {
        print("Image loaded via delegate")
    }

    func imageLoader(_ loader: ImageLoader, didFailWith error: Error) {
        print("Image loading failed: \(error.localizedDescription)")
    }
}
