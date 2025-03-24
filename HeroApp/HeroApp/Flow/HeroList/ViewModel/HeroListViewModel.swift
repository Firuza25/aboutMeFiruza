import SwiftUI
import Combine

final class HeroListViewModel: ObservableObject {
    @Published private(set) var heroes: [HeroListModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = ""
    
    private var allHeroes: [HeroListModel] = []
    private let service: HeroService
    private let router: HeroRouter
    private var cancellables = Set<AnyCancellable>()

    init(service: HeroService, router: HeroRouter) {
        self.service = service
        self.router = router
        
        // Setup search text filtering
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.filterHeroes(with: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterHeroes(with searchText: String) {
        if searchText.isEmpty {
            heroes = allHeroes
        } else {
            heroes = allHeroes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func fetchHeroes() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let heroesResponse = try await service.fetchHeroes()

            await MainActor.run {
                self.allHeroes = heroesResponse.map {
                    HeroListModel(
                        id: $0.id,
                        name: $0.name,
                        fullName: $0.biography.fullName.isEmpty ? $0.name : $0.biography.fullName,
                        race: $0.appearance.race ?? "Unknown",
                        publisher: $0.biography.publisher,
                        alignment: $0.biography.alignment,
                        thumbnailUrl: $0.thumbnailUrl
                    )
                }
                
                // Initial filtering in case search is not empty
                self.filterHeroes(with: self.searchText)
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

    func routeToDetail(by id: Int) {
        router.showDetails(for: id)
    }
}
