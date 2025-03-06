import Foundation
import SwiftUI

@MainActor
final class ViewModel: ObservableObject {
    @Published var selectedHero: Hero?
    @Published var nextHero: Hero?
    @Published var allHeroes: [Hero] = []
    @Published var filteredHeroes: [Hero] = []      
    @Published var searchText: String = ""

    private var isLoadingHero = false

    init() {
        Task {
            await fetchAllHeroes()
        }
    }

    func fetchAllHeroes() async {
        guard let url = URL(string: "https://akabab.github.io/superhero-api/api/all.json") else {
            print("Некорректный URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            allHeroes = try JSONDecoder().decode([Hero].self, from: data)
            filteredHeroes = allHeroes // По умолчанию все герои видны
        } catch {
            print("Ошибка загрузки всех героев: \(error.localizedDescription)")
        }
    }

    func filterHeroes() {
        if searchText.isEmpty {
            filteredHeroes = allHeroes
        } else {
            filteredHeroes = allHeroes.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    func fetchHero() async {
        if let nextHero = nextHero {
            selectedHero = nextHero
            self.nextHero = nil
            await preloadNextHero()
        } else {
            await fetchRandomHero()
        }
    }

    private func preloadNextHero() async {
        guard !isLoadingHero else { return }
        isLoadingHero = true

        if allHeroes.isEmpty {
            await fetchAllHeroes()
        }

        if let newHero = allHeroes.randomElement() {
            self.nextHero = newHero
        }

        isLoadingHero = false
    }

    private func fetchRandomHero() async {
        guard !isLoadingHero else { return }
        isLoadingHero = true

        if allHeroes.isEmpty {
            await fetchAllHeroes()
        }

        if let newHero = allHeroes.randomElement() {
            selectedHero = newHero
        }

        isLoadingHero = false
    }
}
