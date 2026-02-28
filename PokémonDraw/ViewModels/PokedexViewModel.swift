//
//  PokedexViewModel.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import Foundation

@Observable
class PokedexViewModel {
    var allPokemons: [PokemonModel] = []
    var isLoading = false
    
    private var currentOffset: Int = 1
    private let limit: Int = 20
    private let maxPokedexNumber: Int = 1025
    
    deinit {
        print("deinited")
    }
    
    func loadMorePokemons() async {
        guard !isLoading, currentOffset <= maxPokedexNumber else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let startId = currentOffset
        let endId = min(currentOffset + limit - 1, maxPokedexNumber)
        
        do {
            var newPokemon = try await NetworkManager.shared.fetchPokemonBatch(from: startId, to: endId)
            newPokemon = newPokemon.sorted {
                if $0.pokedexNumber == $1.pokedexNumber {
                    return $0.id < $1.id
                }
                return $0.pokedexNumber < $1.pokedexNumber
            }
            
            allPokemons.append(contentsOf: newPokemon)
            currentOffset = endId + 1
        } catch {
            print(error)
        }
    }
    
//    func loadAllPokemons() async  {
//        guard allPokemons.isEmpty else { return } // 이미 로드했으면 생략
//        
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let fetchedPokemons = try await NetworkManager.shared.fetchAllPokemons()
//            // 도감 번호 순으로 정렬, 번호가 같으면(변형 등) ID 순으로 정렬하여 일관성 유지
//            self.allPokemons = fetchedPokemons.sorted {
//                if $0.pokedexNumber == $1.pokedexNumber {
//                    return $0.id < $1.id
//                }
//                return $0.pokedexNumber < $1.pokedexNumber
//            }
//        } catch {
//            print(error)
//        }
//    }
}
