import Foundation

protocol HeroService {
    func fetchHeroes() async throws -> [HeroEntity]
    func fetchHeroById(id: Int) async throws -> HeroEntity
}

enum HeroError: Error, LocalizedError {
    case wrongUrl
    case networkError
    case decodingError
    case serverError(statusCode: Int)
    case noData
    case somethingWentWrong
    
    var errorDescription: String? {
        switch self {
        case .wrongUrl:
            return "Invalid URL"
        case .networkError:
            return "Network connection failed"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noData:
            return "No data received"
        case .somethingWentWrong:
            return "Something went wrong"
        }
    }
}

struct HeroServiceImpl: HeroService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchHeroes() async throws -> [HeroEntity] {
        let urlString = Constants.baseUrl + "all.json"
        guard let url = URL(string: urlString) else {
            throw HeroError.wrongUrl
        }

        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HeroError.networkError
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw HeroError.serverError(statusCode: httpResponse.statusCode)
            }
            
            let heroes = try JSONDecoder().decode([HeroEntity].self, from: data)
            return heroes
        } catch let error as HeroError {
            throw error
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw HeroError.decodingError
        } catch {
            print("Unexpected error: \(error)")
            throw HeroError.somethingWentWrong
        }
    }

    func fetchHeroById(id: Int) async throws -> HeroEntity {
        let urlString = Constants.baseUrl + "id/\(id).json"
        
        guard let url = URL(string: urlString) else {
            throw HeroError.wrongUrl
        }

        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HeroError.networkError
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw HeroError.serverError(statusCode: httpResponse.statusCode)
            }
            
            let hero = try JSONDecoder().decode(HeroEntity.self, from: data)
            return hero
        } catch let error as HeroError {
            throw error
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw HeroError.decodingError
        } catch {
            print("Unexpected error: \(error)")
            throw HeroError.somethingWentWrong
        }
    }
}

private enum Constants {
    static let baseUrl: String = "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/"
}
