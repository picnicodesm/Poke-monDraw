//
//  PokedexView.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import SwiftUI

struct PokedexView: View {
    @State private var viewModel = PokedexViewModel()
    @State private var selectedPokemon: PokemonModel?
    
    // 3열 그리드 레이아웃 정의
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            if viewModel.allPokemons.isEmpty {
                loadingView
            } else {
                VStack {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(viewModel.allPokemons, id: \.id) { pokemon in
                            PokedexCell(pokemon: pokemon)
                                .task {
                                    checkIfNeedToLoadMore(currentPokemon: pokemon)
                                }
                                .onTapGesture {
                                    selectedPokemon = pokemon
                                }
                        }
                    }
                    .padding()
                    
                    if viewModel.isLoading {
                        loadingView
                    }
                }
            }
        }
        .navigationTitle("포켓몬 도감 📖")
        .task {
            if viewModel.allPokemons.isEmpty {
                await viewModel.loadMorePokemons()
            }
        }
        .sheet(item: $selectedPokemon) { pokemon in
            VStack {
                PokemonDetailCard(pokemon: pokemon)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView("도감 로드중...")
                .padding(.top, 50)
        }
    }
    
    private func checkIfNeedToLoadMore(currentPokemon: PokemonModel) {
        guard let lastPokemon = viewModel.allPokemons.last else { return }
        
        if currentPokemon.id == lastPokemon.id {
            Task {
                await viewModel.loadMorePokemons()
            }
        }
    }
}

struct PokedexCell: View {
    let pokemon: PokemonModel
    
    var body: some View {
        VStack(spacing: 8) {
            // 이미지 영역
            AsyncImage(url: URL(string: pokemon.defaultSpriteUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    Image(systemName: "questionmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.gray.opacity(0.3))
                } else {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
            .frame(height: 80)
            .background(
                Circle()
                    .fill(Color.gray.opacity(0.1))
            )
            
            // 정보 영역
            VStack(spacing: 2) {
                Text("No.\(pokemon.pokedexNumber)")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .fontWeight(.bold)
                
                Text(pokemon.koreanName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // 폼 이름이 있다면 작게 표시 (변형 구분용)
                if !pokemon.formName.isEmpty {
                    Text(pokemon.formName)
                        .font(.system(size: 8))
                        .foregroundStyle(.purple)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .background(.purple.opacity(0.1), in: Capsule())
                }
            }
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}


#Preview {
    PokedexView()
}
