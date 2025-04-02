import Foundation
import SwiftUI
import Combine

final class ImagesViewModel: ObservableObject {
    @Published var images: [ImageModel] = []
    @Published var isLoading = false
    
    private let backgroundQueue = DispatchQueue(label: "com.imagedownloader.background", qos: .userInitiated, attributes: .concurrent)
    
    func getImages() {
        guard !isLoading else { return }

        isLoading = true
        let group = DispatchGroup()
        var count = 0
        
        func fetchImages() {
            let remaining = 5 - count
            if remaining <= 0 {
                isLoading = false
                return
            }
            
            let urlStrings: [String] = (0..<remaining).map { _ in
                "https://picsum.photos/id/\(Int.random(in: 0...1000))/500/\(Int.random(in: 400...600))"
            }
            
            for url in urlStrings {
                group.enter()
                downloadImage(urlString: url) { model in
                    if let model = model {
                        DispatchQueue.main.async {
                            self.images.append(model)
                            count += 1
                        }
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                fetchImages()
            }
        }
        
        fetchImages()
    }
    
    private func downloadImage(urlString: String, completion: @escaping (ImageModel?) -> Void) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        backgroundQueue.async {
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                if let safeData = data {
                    guard let image = UIImage(data: safeData) else {
                        print("Cannot create image")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                    
                    let convertedImage = Image(uiImage: image)
                    let height = CGFloat.random(in: 180...250)
                    let model = ImageModel(image: convertedImage, height: height)
                    
                    DispatchQueue.main.async {
                        completion(model)
                    }
                }
            }.resume()
        }
    }
}
