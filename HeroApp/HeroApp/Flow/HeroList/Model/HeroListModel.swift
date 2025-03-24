import Foundation

struct HeroListModel: Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let race: String
    let publisher: String?
    let alignment: String
    let thumbnailUrl: URL?
    

    var description: String {
        let publisherText = publisher ?? "Unknown Publisher"
        return "\(fullName)\n\(race) • \(publisherText) • \(alignment)"
    }
}
