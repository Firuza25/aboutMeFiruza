//
//  HeroDetailView.swift
//  HeroApp
//
//  Created by Firuza on 19.03.2025.
//

import SwiftUI

struct HeroDetailView: View {
    @StateObject var viewModel: HeroDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if let hero = viewModel.heroDetail {
                    heroHeaderView(hero: hero)
                    powerStatsView(hero: hero)
                    
                    Group {
                        sectionTitle("Biography")
                        biographySection(hero: hero)
                        
                        sectionTitle("Appearance")
                        appearanceSection(hero: hero)
                        
                        sectionTitle("Work & Connections")
                        workConnectionsSection(hero: hero)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
        .task {
            await viewModel.fetchHeroDetails()
        }
        .navigationTitle(viewModel.heroDetail?.name ?? "Hero Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading hero details...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Failed to load hero details")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.fetchHeroDetails()
                }
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    private func heroHeaderView(hero: HeroDetailModel) -> some View {
        VStack(spacing: 0) {
            AsyncImage(url: hero.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                case .failure(_):
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(40)
                        .frame(height: 300)
                        .background(Color.gray.opacity(0.3))
                case .empty:
                    ProgressView()
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                @unknown default:
                    Color.gray
                        .frame(height: 300)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(hero.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if !hero.fullName.isEmpty && hero.fullName != hero.name {
                    Text(hero.fullName)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                if !hero.aliasesString.isEmpty {
                    Text("Also known as: \(hero.aliasesString)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label(hero.race, systemImage: "person.fill")
                    Spacer()
                    Label(hero.publisher, systemImage: "book.fill")
                    Spacer()
                    Label(hero.alignment.capitalized, systemImage: "heart.fill")
                }
                .font(.caption)
                .padding(.top, 4)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func powerStatsView(hero: HeroDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Power Stats")
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                powerStatBar(label: "Intelligence", value: hero.intelligence)
                powerStatBar(label: "Strength", value: hero.strength)
                powerStatBar(label: "Speed", value: hero.speed)
                powerStatBar(label: "Durability", value: hero.durability)
                powerStatBar(label: "Power", value: hero.power)
                powerStatBar(label: "Combat", value: hero.combat)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            .padding(.horizontal)
        }
    }
    
    private func powerStatBar(label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(value)/100")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 10)
                        .opacity(0.1)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(value) / 100.0 * geometry.size.width, geometry.size.width), height: 10)
                        .foregroundColor(statColor(for: value))
                }
                .cornerRadius(5)
            }
            .frame(height: 10)
        }
    }
    
    private func statColor(for value: Int) -> Color {
        switch value {
        case 0..<30:
            return .red
        case 30..<60:
            return .orange
        case 60..<80:
            return .yellow
        default:
            return .green
        }
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.top, 8)
    }
    
    private func biographySection(hero: HeroDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow(label: "Place of Birth", value: hero.placeOfBirth)
            infoRow(label: "First Appearance", value: hero.firstAppearance)
            infoRow(label: "Publisher", value: hero.publisher)
            infoRow(label: "Alignment", value: hero.alignment.capitalized)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private func appearanceSection(hero: HeroDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow(label: "Gender", value: hero.gender)
            infoRow(label: "Race", value: hero.race)
            infoRow(label: "Height", value: hero.height)
            infoRow(label: "Weight", value: hero.weight)
            infoRow(label: "Eye Color", value: hero.eyeColor)
            infoRow(label: "Hair Color", value: hero.hairColor)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private func workConnectionsSection(hero: HeroDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow(label: "Occupation", value: hero.occupation)
            infoRow(label: "Base", value: hero.base)
            infoRow(label: "Group Affiliation", value: hero.groupAffiliation)
            infoRow(label: "Relatives", value: hero.relatives)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value.isEmpty ? "Unknown" : value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}
