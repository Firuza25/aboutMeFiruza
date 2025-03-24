//
//  HeroDetailModel.swift
//  HeroApp
//
//  Created by Firuza on 19.03.2025.
//

import Foundation

struct HeroDetailModel: Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let imageUrl: URL?
    
    // Appearance
    let gender: String
    let race: String
    let height: String
    let weight: String
    let eyeColor: String
    let hairColor: String
    
    // Biography
    let aliases: [String]
    let placeOfBirth: String
    let firstAppearance: String
    let publisher: String
    let alignment: String
    
    // Power stats
    let intelligence: Int
    let strength: Int
    let speed: Int
    let durability: Int
    let power: Int
    let combat: Int
    
    // Work & Connections
    let occupation: String
    let base: String
    let groupAffiliation: String
    let relatives: String
    
    // Computed properties
    var powerStatsTotal: Int {
        intelligence + strength + speed + durability + power + combat
    }
    
    var aliasesString: String {
        aliases.joined(separator: ", ")
    }
}
