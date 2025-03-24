import SwiftUI

struct HeroListView: View {
    @StateObject var viewModel: HeroListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar
            
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading heroes...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Error loading heroes")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Try Again") {
                            Task {
                                await viewModel.fetchHeroes()
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .padding()
                    }
                } else if viewModel.heroes.isEmpty {
                    if viewModel.searchText.isEmpty {
                        Text("No heroes found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No matches found for '\(viewModel.searchText)'")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    listOfHeroes()
                }
            }
        }
        .navigationTitle("SuperHeroes")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if viewModel.heroes.isEmpty {
                await viewModel.fetchHeroes()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search heroes", text: $viewModel.searchText)
                .disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

extension HeroListView {
    @ViewBuilder
    private func listOfHeroes() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.heroes) { model in
                    heroCard(model: model)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.routeToDetail(by: model.id)
                        }
                }
                .padding(.vertical, 8)
            }
        }
    }

    @ViewBuilder
    private func heroCard(model: HeroListModel) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: model.thumbnailUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                case .failure(_):
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                @unknown default:
                    Color.gray
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if !model.fullName.isEmpty && model.fullName != model.name {
                    Text(model.fullName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text("\(model.race) • \(model.alignment.capitalized)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let publisher = model.publisher, !publisher.isEmpty {
                    Text(publisher)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
        .animation(.default, value: model.id)
    }
}
