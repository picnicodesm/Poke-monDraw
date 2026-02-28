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
    private let batchSize: Int = 20
    private let maxPokedexNumber: Int = 1025
    
    deinit {
        print("deinited")
    }
    
    func loadAllPokemons() async  {
        guard allPokemons.isEmpty else { return } // 이미 로드했으면 생략
        
        isLoading = true
        defer { isLoading = false }
        
        for currentId in stride(from: 1, through: maxPokedexNumber, by: batchSize) {
            let endId = min(currentId + batchSize - 1, maxPokedexNumber)
            
            do {
                // 백그라운드(NetworkManager)에서 20개 가져오기
                let newPokemons = try await NetworkManager.shared.fetchPokemonBatch(from: currentId, to: endId)
                let sortedNewPokemons = newPokemons.sorted {
                    if $0.pokedexNumber == $1.pokedexNumber {
                        return $0.id < $1.id
                    }
                    return $0.pokedexNumber < $1.pokedexNumber
                }
                
                self.allPokemons.append(contentsOf: sortedNewPokemons)
                
            } catch {
                print("포켓몬 로딩 에러: \(error.localizedDescription)")
            }
        }
        
    }
}
