//
//  ContentView.swift
//  APIsBeginnerPractice
//
//  Created by Danielle Abrams on 12/7/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack (spacing: 20){
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundStyle(.gray)
                    
            }
            .frame(width: 120, height: 120)
            
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "Bio Please")
                .padding()
            
                Spacer()
        }
        .padding()
        .task { // Throws errors if it falls any of these actions
            do {
                user = try await getUser()
            } catch GHError.invalidURL  {
                print("invalid URL")
            } catch GHError.invalideResponse {
                print("invalid response")
            } catch GHError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
    }
    // Normally in a ViewModel file seperately
    
    func getUser() async throws -> GitHubUser {
       let endpoint = "https://api.github.com/users/daniabrams333"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalideResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
        
    }
}

#Preview {
    ContentView()
}


struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalideResponse
    case invalidData
}
