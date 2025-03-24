//
//  HeroDetailViewModel.swift
//  HeroApp
//
//  Created by Firuza on 19.03.2025.
//

import SwiftUI
import Combine

final class HeroDetailViewModel: ObservableObject {
    @Published private(set) var heroDetail: HeroDetailModel?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let service: HeroService
    private let heroId: Int
    
    init(service: HeroService, heroId: Int) {
        self.service = service
        self.heroId = heroId
    }
    
    func fetchHeroDetails() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let hero = try await service.fetchHeroById(id: heroId)
            
            await MainActor.run {
                self.heroDetail = HeroDetailModel(
                    id: hero.id,
                    name: hero.name,
                    fullName: hero.biography.fullName.isEmpty ? hero.name : hero.biography.fullName,
                    imageUrl: hero.heroImageUrl,
                    
                    gender: hero.appearance.gender,
                    race: hero.appearance.race ?? "Unknown",
                    height: hero.appearance.height.last ?? "Unknown",
                    weight: hero.appearance.weight.last ?? "Unknown",
                    eyeColor: hero.appearance.eyeColor,
                    hairColor: hero.appearance.hairColor,
                    
                    aliases: hero.biography.aliases,
                    placeOfBirth: hero.biography.placeOfBirth,
                    firstAppearance: hero.biography.firstAppearance,
                    publisher: hero.biography.publisher ?? "Unknown",
                    alignment: hero.biography.alignment,
                    
                    intelligence: hero.powerstats.intelligence,
                    strength: hero.powerstats.strength,
                    speed: hero.powerstats.speed,
                    durability: hero.powerstats.durability,
                    power: hero.powerstats.power,
                    combat: hero.powerstats.combat,
                    
                    occupation: hero.work.occupation,
                    base: hero.work.base,
                    groupAffiliation: hero.connections.groupAffiliation,
                    relatives: hero.connections.relatives
                )
                self.isLoading = false
            }
        } catch let error as HeroError {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Unexpected error occurred"
                self.isLoading = false
            }
        }
    }
}
