//
//  Hero.swift
//  HeroRandomizer
//
//  Created by Firuza on 06.03.2025.
//

import Foundation

struct Hero: Decodable, Identifiable {
    let id: Int
    let name: String
    let powerstats: Powerstats
    let images: Image
    
    var imageUrl: URL? {
        URL(string: images.md)
    }
    
    struct Powerstats: Decodable {
        let intelligence: Int
        let strength: Int
        let speed: Int
        let durability: Int
        let power: Int
        let combat: Int
    }

    struct Image: Decodable {
        let md: String
    }
}
