//
//  TabBarController.swift
//  MM-lab2
//
//  Created by Firuza on 28.02.2025.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileVC = UserProfileViewController()
        let feedVC = FeedViewController()

        // Assign tab bar items with titles and system icons
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 0)
        feedVC.tabBarItem = UITabBarItem(title: "NEWS", image: UIImage(systemName: "list.bullet.rectangle"), tag: 1)
        
        // Embed in navigation controllers (optional but recommended)
        let feedNav = UINavigationController(rootViewController: feedVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        viewControllers = [feedNav, profileNav]
    }
}
