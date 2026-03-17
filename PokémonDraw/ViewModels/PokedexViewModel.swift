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
        
        guard currentOffset <= maxPokedexNumber else { return }
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        for currentId in stride(from: currentOffset, through: maxPokedexNumber, by: batchSize) {
            guard !Task.isCancelled else {
                currentOffset = currentId // 멈춘 곳 저장
                return
            }
            
            let endId = min(currentId + batchSize - 1, maxPokedexNumber)
            
            do {
                let newPokemons = try await NetworkManager.shared.fetchPokemonBatch(from: currentId, to: endId)
                let sortedNewPokemons = newPokemons.sorted {
                    if $0.pokedexNumber == $1.pokedexNumber {
                        return $0.id < $1.id
                    }
                    return $0.pokedexNumber < $1.pokedexNumber
                }
                
                self.allPokemons.append(contentsOf: sortedNewPokemons)
                currentOffset = currentId + batchSize // 성공했을 때 업데이트
                
            } catch is CancellationError {
                currentOffset = currentId // 멈춘 곳 저장
                return
            }
            catch {
                print("포켓몬 로딩 에러: \(error.localizedDescription)")
            }
        }
        
    }
}
