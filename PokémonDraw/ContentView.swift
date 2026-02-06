//
//  ContentView.swift
//  PokémonDraw
//
//  Created by picnic on 2/4/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = PokemonDrawViewModel()
    @State private var isFetching = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                let pokemon = viewModel.pokemon.first
                if let pokemon = pokemon {
                    VStack {
                        AsyncImage(url: URL(string: pokemon.defaultSpriteUrl))
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .aspectRatio(contentMode: .fit)
                        Text("이름: \(pokemon.koreanName)")
                        Text("\(pokemon.flavorText)")
                        Text("타입: \(pokemon.types)")
                        Text("키: \(pokemon.height)m")
                        Text("분류: \(pokemon.classification)")
                        Text("성별: \(pokemon.gender)")
                        Text("몸무게: \(pokemon.weight)kg")
                    }
                    .frame(width: 300, height: 480)
                    .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    VStack {
                        if isFetching {
                            ProgressView()
                        } else {
                            Text("포켓몬을 뽑아보세요!")
                        }
                    }
                    .frame(width: 300, height: 480)
                    .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button("fetch") {
                    Task {
                        do {
                            try await viewModel.fetchRandomPokemon()
                        } catch {
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("포켓몬 뽑기 🏀")
        }
    }
}

#Preview {
    ContentView()
}
