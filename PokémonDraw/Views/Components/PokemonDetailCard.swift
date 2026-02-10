//
//  PokemonDetailCard.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import SwiftUI

struct PokemonDetailCard: View {
    let pokemon: PokemonModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. 고화질 아트워크
                AsyncImage(url: URL(string: pokemon.officialArtworkUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: 10)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    } else {
                        ProgressView()
                    }
                }
                .frame(height: 250)
                .padding(.top)
                
                // 2. 기본 정보 섹션
                VStack(spacing: 8) {
                    Text(pokemon.koreanName)
                        .font(.title)
                        .fontWeight(.black)
                    
                    if !pokemon.formName.isEmpty {
                        Text(pokemon.formName)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    
                    Text(pokemon.classification)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                
                Divider()
                
                // 3. 속성 및 스펙 그리드
                Grid(horizontalSpacing: 30, verticalSpacing: 15) {
                    GridRow {
                        StatItem(title: "타입", value: pokemon.types.joined(separator: ", "))
                        StatItem(title: "성별", value: pokemon.gender)
                    }
                    GridRow {
                        StatItem(title: "키", value: String(format: "%.1fm", pokemon.height))
                        StatItem(title: "몸무게", value: String(format: "%.1fkg", pokemon.weight))
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // 4. 도감 설명
                VStack(alignment: .leading, spacing: 10) {
                    Text("도감 설명")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    Text(pokemon.flavorText)
                        .font(.body)
                        .lineSpacing(5)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

// 재사용 가능한 스탯 아이템 뷰
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    PokemonDetailCard(pokemon: PokemonModel.mock[2])
}
