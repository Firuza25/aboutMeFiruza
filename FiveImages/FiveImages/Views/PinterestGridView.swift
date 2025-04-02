//
//  PinterestGridView.swift
//  FiveImages
//
//  Created by Firuza on 02.04.2025.
//

import SwiftUI

struct PinterestGridView: View {
    let columns = 2
    let images: [ImageModel]
    let spacing: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let width = (geometry.size.width / CGFloat(columns)) - (spacing * 2)
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: spacing * 2), count: columns),
                    spacing: spacing * 2
                ) {
                    ForEach(images) { model in
                        model.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: model.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
