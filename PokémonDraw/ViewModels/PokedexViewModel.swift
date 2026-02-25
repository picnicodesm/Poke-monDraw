//
//  PokedexViewModel.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import Foundation

@Observable
class PokedexViewModel {
    private let networkManager = NetworkManager()
    var allPokemons: [PokemonModel] = []
    var isLoading = false
    
    deinit {
        print("deinited")
    }
    
    func loadAllPokemons() async  {
        guard allPokemons.isEmpty else { return } // 이미 로드했으면 생략
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedPokemons = try await networkManager.fetchAllPokemons()
            // 도감 번호 순으로 정렬, 번호가 같으면(변형 등) ID 순으로 정렬하여 일관성 유지
            self.allPokemons = fetchedPokemons.sorted {
                if $0.pokedexNumber == $1.pokedexNumber {
                    return $0.id < $1.id
                }
                return $0.pokedexNumber < $1.pokedexNumber
            }
        } catch {
            print(error)
        }
    }
}
