//
//  ContentView.swift
//  FiveImages
//
//  Created by Arman Myrzakanurov on 28.03.2025.
//
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ImagesViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                Text("Pinterest Gallery")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top  ?? 0)
                
                if viewModel.images.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image("Pinterest-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)

                        Text("Welcome to my Pinterest board!")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Tap the button below to load images")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    PinterestGridView(images: viewModel.images, spacing: 10)
                        .padding(.vertical, 5)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.getImages()
                }) {
                    Text(viewModel.isLoading ? "Loading..." : "Give me 5 random pins")
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color(red: 189/255, green: 8/255, blue: 28/255)) // Цвет #BD081C
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                .padding(.bottom)
            }
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
