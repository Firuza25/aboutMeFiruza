//
//  ContentView.swift
//  HeroRandomizer
//
//  Created by Arman Myrzakanurov on 28.02.2025.
//
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            backgroundGradient

            VStack {
                searchField

                if viewModel.searchText.isEmpty {
                    mainHeroView
                } else {
                    searchResultsView
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchAllHeroes() }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(colors: [.purple, .black],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }

    private var searchField: some View {
        TextField("Hero Search", text: $viewModel.searchText)
            .textFieldStyle(.plain)
            .padding(12)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .foregroundColor(.white)
            .font(.system(size: 18, weight: .medium))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
            .onChange(of: viewModel.searchText) { _ in
                viewModel.filterHeroes()
            }
    }

    private var mainHeroView: some View {
        VStack {
            Spacer()
            if let hero = viewModel.selectedHero {
                HeroCardView(hero: hero)
            } else {
                Text("Tap to reveal a hero!")
                    .foregroundColor(.white)
                    .font(.title2)
                    .bold()
                    .shadow(radius: 5)
            }
            Spacer()
            Button("Next Hero") {
                Task { await viewModel.fetchHero() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .padding(.bottom, 50)
        }
    }

    private var searchResultsView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                ForEach(viewModel.filteredHeroes) { hero in
                    HeroCardView(hero: hero)
                }
            }
            .padding()
        }
    }
}


#Preview {
    ContentView(viewModel: ViewModel())
}
