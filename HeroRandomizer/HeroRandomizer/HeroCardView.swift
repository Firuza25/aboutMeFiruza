//
//  HeroCardView.swift
//  HeroRandomizer
//
//  Created by Firuza on 06.03.2025.
//

import SwiftUI

struct HeroCardView: View {
    let hero: Hero
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            if isFlipped {
                backSide
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                frontSide
            }
        }
        .frame(width: 300, height: 450)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring()) {
                isFlipped.toggle()
            }
        }
    }

    private var frontSide: some View {
        VStack {
            AsyncImage(url: hero.imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 350)

                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                case .failure:
                    Color.red.frame(height: 350)

                @unknown default:
                    EmptyView()
                }
            }

            Text(hero.name)
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .shadow(color: .purple, radius: 5)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.1)))
    }

    private var backSide: some View {
        VStack {
            Text(hero.name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 10)

            Spacer()

            PowerStatBars(powerstats: hero.powerstats)

            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.8)))
    }
}
