//
//  StoreView.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import SwiftUI
import SwiftData

struct StoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode
    
    @Query(sort: \MyPokemon.id) private var savedPokemons: [MyPokemon]
    @State private var selectedPokemon: PokemonModel? // 모달용 (구조체로 변환하여 사용)
    @State private var showDeleteAlert = false
    @State private var pokemonToDelete: MyPokemon?
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            if savedPokemons.isEmpty {
                emptyView
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(savedPokemons) { myPokemon in
                        ZStack(alignment: .topTrailing) {
                            StoreCell(pokemon: myPokemon)
                                .onTapGesture {
                                    if editMode?.wrappedValue.isEditing == false {
                                        selectedPokemon = myPokemon.toStruct
                                    }
                                }
                            
                            if editMode?.wrappedValue.isEditing == true {
                                Button {
                                    pokemonToDelete = myPokemon
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.red)
                                        .background(Circle().fill(.white))
                                        .offset(x: 5, y: -5)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .animation(.default, value: editMode?.wrappedValue.isEditing)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("내 보관함")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .alert("포켓몬 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { pokemonToDelete = nil }
            Button("확인", role: .destructive) {
                if let pokemon = pokemonToDelete {
                    deletePokemon(pokemon)
                }
            }
        } message: {
            if let name = pokemonToDelete?.koreanName {
                Text("\(name)을(를) 보관함에서 삭제하시겠습니까?")
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
    
    private func deletePokemon(_ pokemon: MyPokemon) {
        modelContext.delete(pokemon)
        // SwiftData는 보통 자동 저장되지만, 명시적으로 처리하고 싶다면 try? modelContext.save() 사용 가능
        pokemonToDelete = nil
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text("아직 저장된 포켓몬이 없습니다.")
                .font(.headline)
                .foregroundStyle(.gray)
        }
        .padding(.top, 100)
    }
}

struct StoreCell: View {
    let pokemon: MyPokemon
    
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
                
                // 폼 이름 표시
                if !pokemon.formName.isEmpty {
                    Text(pokemon.formName)
                        .font(.system(size: 8))
                        .foregroundStyle(.orange) // 보관함은 구분되게 주황색 포인트
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .background(.orange.opacity(0.1), in: Capsule())
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
