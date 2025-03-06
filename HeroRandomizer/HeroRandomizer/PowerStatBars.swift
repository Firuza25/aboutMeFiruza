//
//  PowerStatBars.swift
//  HeroRandomizer
//
//  Created by Firuza on 06.03.2025.
//
import SwiftUI

struct PowerStatBars: View {
    let powerstats: Hero.Powerstats

    var body: some View {
        VStack {
            Text("Power Levels")
                .font(.headline)
                .foregroundColor(.cyan)

            PowerStatBar(label: "Intelligence", value: powerstats.intelligence, color: .yellow)
            PowerStatBar(label: "Strength", value: powerstats.strength, color: .red)
            PowerStatBar(label: "Speed", value: powerstats.speed, color: .blue)
            PowerStatBar(label: "Durability", value: powerstats.durability, color: .orange)
            PowerStatBar(label: "Power", value: powerstats.power, color: .purple)
            PowerStatBar(label: "Combat", value: powerstats.combat, color: .green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
                .shadow(color: .cyan, radius: 10)
        )
    }
}

struct PowerStatBar: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)

                Spacer()

                Text("\(value)")
                    .font(.caption)
                    .foregroundColor(.cyan)
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 200, height: 10)
                    .foregroundColor(Color.gray.opacity(0.3))

                RoundedRectangle(cornerRadius: 10)
                    .frame(width: CGFloat(value) * 2, height: 8)
                    .foregroundColor(color)
                    .shadow(color: color, radius: 5)
            }
        }
    }
}


#Preview {
    PowerStatBars(powerstats: Hero.Powerstats(
        intelligence: 80,
        strength: 90,
        speed: 75,
        durability: 85,
        power: 95,
        combat: 70
    ))
}
