//
//  PokemonDrawViewModel.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import Foundation

@Observable
class PokemonDrawViewModel {
    var isFetching = false
    
    var pokemon: [PokemonModel] = []
    
    func fetchRandomPokemon() async {
        do {
            isFetching = true
            defer { isFetching = false }
            
            pokemon =  try await NetworkManager.shared.fetchRandomPokemon()
        } catch {
            print(error)
        }
    }
}
