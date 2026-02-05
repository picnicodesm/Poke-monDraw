//
//  NetworkManager.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation

class NetworkManager {
    // default url: https://pokeapi.co/api/v2/pokemon/{id}/
    // species: https://pokeapi.co/api/v2/pokemon-species/{id}/
    
    func fetchPokemon() async throws {
        // 1. default url에서 PokemonBasicDTO 얻기
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(PokemonBasicDTO.self, from: data)
            
        
        // 2. species url에서 PokemonSpeciesDTO 얻기
        let speciesUrl = URL(string: dto.species.url)!
        let (speciesData, _) = try await URLSession.shared.data(from: speciesUrl)
        let speciesDto = try decoder.decode(PokemonSpeciesDTO.self, from: speciesData)

        print(speciesDto)
        
        // 3. 필요 정보는 DTO에서 필터링
    }
    
}
