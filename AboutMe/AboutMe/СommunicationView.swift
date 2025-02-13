//
//  EducationView.swift
//  AboutMe
//
//  Created by Firuza on 06.02.2025.
//

import SwiftUI

struct CommunicationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("For communication")
                .font(.largeTitle)
                .bold()
            
            Image("stop")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text("You can contact me via:")
                .font(.title2)
            
            VStack(spacing: 10) {
                ForEach([
                    ("Instagram", "https://www.instagram.com/_f1rumdza_/"),
                    ("GitHub", "https://github.com/Firuza25"),
                    ("LinkedIn", "https://www.linkedin.com/in/firuza-undefined-955540328/")
                ], id: \.0) { contact in
                    Button(action: {
                        if let link = URL(string: contact.1) {
                            UIApplication.shared.open(link)
                        }
                    }) {
                        Text(contact.0)
                            .font(.title3)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }
}

struct CommunicationView_Previews: PreviewProvider {
    static var previews: some View {
        CommunicationView()
    }
}
