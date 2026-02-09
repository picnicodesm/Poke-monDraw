//
//  StoreView.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import SwiftUI
import SwiftData

struct StoreView: View {
    // ✨ SwiftData에서 도감 번호 순으로 정렬하여 데이터 가져오기
    @Query(sort: \MyPokemon.pokedexNumber) private var savedPokemons: [MyPokemon]
    @State private var selectedPokemon: PokemonModel? // 모달용 (구조체로 변환하여 사용)
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            if savedPokemons.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 60))
                        .foregroundStyle(.gray)
                    Text("아직 저장된 포켓몬이 없습니다.")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Text("뽑기 화면에서 마음에 드는 포켓몬을 저장해보세요!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(savedPokemons) { myPokemon in
                        StoreCell(pokemon: myPokemon)
                            .onTapGesture {
                                // ✨ 저장된 Class 객체를 UI용 Struct로 변환하여 모달에 전달
                                selectedPokemon = myPokemon.toStruct
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("내 보관함 📦")
        // ✨ 상세 보기 모달 (재사용)
        .sheet(item: $selectedPokemon) { pokemon in
            VStack {
                PokemonDetailCard(pokemon: pokemon)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// 📦 보관함 전용 셀 (MyPokemon 객체 사용)
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


//#Preview {
//    NavigationStack {
//        StoreView()
//    }
//}
