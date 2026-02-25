//
//  PokemonDrawViewModel.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import Foundation

@Observable
class PokemonDrawViewModel {
    private let networkManager = NetworkManager()
    private var fetchTask: Task<Void, Never>? = nil
    var isFetching = false
    
    var pokemon: [PokemonModel] = []
    
    func fetchRandomPokemon() {
        fetchTask?.cancel()
        
        fetchTask = Task {
            do {
                isFetching = true
                defer { isFetching = false }
                
                pokemon =  try await networkManager.fetchRandomPokemon()
            } catch {
                print(error)
            }
            
            fetchTask = nil
        }
    }
}
