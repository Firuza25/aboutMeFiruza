//
//  ImageLoader.swift
//  MM-lab2
//
//  Created by Firuza on 28.02.2025.
//

import Foundation
import UIKit

protocol ImageLoaderDelegate: AnyObject {
    func imageLoader(_ loader: ImageLoader, didLoad image: UIImage)
    func imageLoader(_ loader: ImageLoader, didFailWith error: Error)
}

class ImageLoader {
    weak var delegate: ImageLoaderDelegate?
    var completionHandler: ((UIImage?) -> Void)?

    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.imageLoader(self, didFailWith: error)
                    self.completionHandler?(nil)
                }
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.delegate?.imageLoader(self, didLoad: image)
                    self.completionHandler?(image)
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.imageLoader(self, didFailWith: NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))
                    self.completionHandler?(nil)
                }
            }
        }.resume()
    }
}
