//
//  ContentView.swift
//  PokémonDraw
//
//  Created by picnic on 2/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PokemonDrawViewModel()
    @State private var showDetailModal = false
    @State private var isSaved = false
    @State private var pokedexViewModel = PokedexViewModel()
    
#if DEBUG
    @State private var debugTask: Task<Void, Never>? = nil
#endif
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                
                // 메인 카드 영역
                mainCardView
                    .onTapGesture {
                        if !viewModel.pokemon.isEmpty {
                            showDetailModal = true
                        }
                    }
                
                Spacer()
                
                // 뽑기 버튼
                Button {
                    isSaved = false
                    Task {
                        await viewModel.fetchRandomPokemon()
                    }
                } label: {
                    Text(viewModel.isFetching ? "포켓몬 찾는 중..." : "새로운 포켓몬 뽑기 🎲")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFetching ? .gray : .blue)
                        .cornerRadius(15)
                }
                .disabled(viewModel.isFetching)
                
                if !viewModel.pokemon.isEmpty {
                    Button {
                        savePokemon()
                    } label: {
                        HStack {
                            Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down.fill")
                            Text(isSaved ? "저장 완료" : "보관함에 저장하기")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSaved ? .gray : .green)
                        .cornerRadius(15)
                    }
                    .disabled(isSaved) // 저장 후 비활성화
                }
                
#if DEBUG
                HStack {
                    Button {
                        print(viewModel.pokemon)
                    } label: {
                        Text("뽑은 포켓몬 정보 출력")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        let vm = PokedexViewModel()
                        debugTask?.cancel()
                        
                        debugTask =  Task {
                            await vm.loadAllPokemons()
                            
                            debugTask = nil
                        }
                    } label: {
                        Text("전체 포켓몬 조회")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        debugTask?.cancel()
                    } label: {
                        Text("전체 포켓몬 조회 취소")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(height: 100)
#endif
            }
            .padding()
            .navigationTitle("포켓몬 뽑기 🏀")
            .sheet(isPresented: $showDetailModal) {
                VStack {
                    TabView {
                        ForEach(viewModel.pokemon, id: \.id) { pokemon in
                            PokemonDetailCard(pokemon: pokemon, useCache: false)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        StoreView()
                    } label: {
                        Image(systemName: "archivebox.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        PokedexView(viewModel: $pokedexViewModel)
                    } label: {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainCardView: some View {
        if let mainPokemon = viewModel.pokemon.first {
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: mainPokemon.defaultSpriteUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 220, height: 220)
                .background(
                    Circle()
                        .fill(.white.opacity(0.2))
                        .blur(radius: 10)
                )
                
                VStack(spacing: 5) {
                    Text(mainPokemon.koreanName)
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.white)
                    
                    Text("터치하여 상세 정보 보기")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                // 간단한 뱃지 (폼이 여러 개면 알려줌)
                if viewModel.pokemon.count > 1 {
                    Text("+\(viewModel.pokemon.count - 1)개의 다른 모습")
                        .font(.caption)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 450)
            .background(
                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
        } else {
            VStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.5))
                Text("오늘의 파트너는 누구?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 450)
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }
    
    private func savePokemon() {
        for pokemon in viewModel.pokemon {
            let myPokemon = MyPokemon(from: pokemon)
            modelContext.insert(myPokemon)
        }
        
        withAnimation {
            isSaved = true
        }
        print("포켓몬 저장 완료")
    }
}

#Preview {
    ContentView()
}
