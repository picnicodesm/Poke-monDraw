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
    @State private var showDetailModal = false // 모달 표시 여부
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
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
                    Task {
                        isFetching = true
                        do {
                            // fetchRandomPokemon이 [PokemonModel]을 반환하거나
                            // viewModel.pokemon을 업데이트한다고 가정
                            try await viewModel.fetchRandomPokemon()
                        } catch {
                            print("Error: \(error)")
                        }
                        isFetching = false
                    }
                } label: {
                    Text(isFetching ? "포켓몬 찾는 중..." : "새로운 포켓몬 뽑기 🎲")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFetching ? .gray : .blue)
                        .cornerRadius(15)
                }
                .disabled(isFetching)
                
                Button {
                    print(viewModel.pokemon)
                } label: {
                    Text("결과 콘솔에서 보기")
                }
            }
            .padding()
            .navigationTitle("포켓몬 뽑기 🏀")
            // ✨ 상세 정보 모달 (Sheet)
            .sheet(isPresented: $showDetailModal) {
                // 상단에 닫기 버튼 등을 넣기 위해 NavigationView 사용 가능
                VStack {
                    // ✨ 페이징 뷰 구현
                    TabView {
                        ForEach(viewModel.pokemon, id: \.id) { pokemon in
                            PokemonDetailCard(pokemon: pokemon)
                            // 탭뷰 페이징 시 태그 필요할 수 있음 (선택 구현)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always)) // 페이지 인디케이터 표시
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
                .presentationDetents([.medium, .large]) // 절반 혹은 전체 화면으로 조절 가능
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // 메인 화면에 보여줄 심플한 카드 뷰 (ViewBuilder 활용)
    @ViewBuilder
    var mainCardView: some View {
        if let mainPokemon = viewModel.pokemon.first {
            VStack(spacing: 20) {
                // 메인 이미지 (스프라이트)
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
            // 대기 화면
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
}

#Preview {
    ContentView()
}
