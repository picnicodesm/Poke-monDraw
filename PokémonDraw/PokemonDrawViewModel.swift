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
    var pokemon: [PokemonModel] = []
    
    func fetchRandomPokemon() async throws {
        Task {
            pokemon =  try await networkManager.fetchRandomPokemon()
        }
    }
    
}
