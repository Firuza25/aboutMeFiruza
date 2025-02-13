//
//  ProfileView.swift
//  AboutMe
//
//  Created by Firuza on 06.02.2025.
//
import SwiftUI

struct ProfileView: View {
    @State private var isDarkMode = false 

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        isDarkMode.toggle()
                    }
                }) {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.primary)
                }
            }

            Image("myPhoto")
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.primary, lineWidth: 2))
                .shadow(radius: 10)

            Text("Firuza Sagatkyzy")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("19 y.o, KBTU(SITE)")
                .font(.system(size: 20))
                .foregroundColor(.gray)
              
            

            Text("a bestie of the tuda suda millionaire girl💅🏻")
                .foregroundColor(.primary)
                .padding()
                .font(Font.custom("GrechenFuemen-Regular", size: 25))
            
            Text("my life motto:")
                .foregroundColor(.gray)
                .font(.system(size: 14))
            
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.purple.opacity(0.2))
                .frame(width: 320)
                .padding(.top, 12)
                .overlay(
                    Text("🎯 \"Вкладывай в дело душу, и жизнь тебя наградит.\"")
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding()
                        
                )
            
        }
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
