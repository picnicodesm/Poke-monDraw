//
//  NetworkManager.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation

class NetworkManager {
    
    @concurrent
    func fetchRandomPokemon() async throws -> [PokemonModel] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let randomNumber = Int.random(in: 1...1025)
        let pokemon = try await fetchPokemon(id: randomNumber)
        
        return pokemon
    }
    
    @concurrent
    func fetchAllPokemons() async throws -> [PokemonModel] {
        var results: [PokemonModel] = []
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        try await withThrowingTaskGroup(of: [PokemonModel].self) { group in
            for i in 1...1025 {
                group.addTask { [self] in
                    return try await fetchPokemon(id: i)
                }
            }
            
            for try await pokemons in group {
                results += pokemons
            }
        }
        
        return results
    }
}

extension NetworkManager {
    
    @concurrent
    private func fetchPokemon(id: Int) async throws -> [PokemonModel] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // 1. default url에서 PokemonBasicDTO 얻기
        let dto = try await self.fetchPokemon(for: id, decoder: decoder)
        
        // 2. species url에서 PokemonSpeciesDTO 얻기
        let speciesDto = try await self.fetchPokemonSpecies(from: dto.speciesUrl, decoder: decoder)
        
        // 3. 폼에 대한 정보 얻기
        let formDtos = try await self.fetchForms(from: dto.formsUrls, decoder: decoder)
        
        // 4. species의 isDefault가 false인게 있다면 해당 변형에 대해 얻기
        let varities = speciesDto.nonDefaultVarities
        let varitiesDtos = try await self.fetchVarities(from: varities, decoder: decoder)
        
        // 5. 변형별 폼 정보 얻기
        let varityFormDtos = try await self.fetchForms(from: varitiesDtos, decoder: decoder)
        
        // 리턴할 정보
        var pokemons: [PokemonModel] = []
        pokemons += self.createModel(with: (dto, speciesDto, formDtos))
        pokemons += self.createModel(basic: dto, species: speciesDto, forms: varityFormDtos, varities: varitiesDtos)
        
        return pokemons
    }
    
    @concurrent
    private func fetchPokemon(for id: Int, decoder: JSONDecoder) async throws ->  PokemonBasicDTO {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)/")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let dto = try decoder.decode(PokemonBasicDTO.self, from: data)
        
        return dto
    }
    
    @concurrent
    private func fetchPokemonSpecies(from urlString: String, decoder: JSONDecoder) async throws -> PokemonSpeciesDTO {
        let speciesUrl = URL(string: urlString)!
        let (speciesData, _) = try await URLSession.shared.data(from: speciesUrl)
        let speciesDto = try decoder.decode(PokemonSpeciesDTO.self, from: speciesData)
        
        return speciesDto
    }
    
    @concurrent
    private func fetchForms(from urlStrings: [String], decoder: JSONDecoder) async throws -> [FormDTO] {
        var formDtos: [FormDTO] = []
        
        try await withThrowingTaskGroup(of: FormDTO.self) { group in
            for formUrlString in urlStrings {
                group.addTask {
                    let formUrl = URL(string: formUrlString)!
                    
                    let (data, _) = try await URLSession.shared.data(from: formUrl)
                    let formDto = try decoder.decode(FormDTO.self, from: data)
                    
                    return formDto
                }
            }
            
            for try await formDto in group {
                formDtos.append(formDto)
            }
        }
        
        return formDtos
    }
    
    /// 포켓몬에 여러 변형들로부터 각각의 폼 정보를 얻는 함수
    /// 변형 하나에는 폼이 하나. 폼의 이름은 없을수도, 한국어가 없을 수도, 있을 수도 있다.
    @concurrent
    private func fetchForms(from dtos: [PokemonBasicDTO], decoder: JSONDecoder) async throws -> [FormDTO] {
        var formDtos: [FormDTO] = []
        
        guard !dtos.isEmpty else { return formDtos }
        
        try await withThrowingTaskGroup(of: FormDTO.self) { group in
            for dto in dtos {
                guard let formUrlString = dto.formsUrls.first else { continue }
                
                group.addTask {
                    let formUrl = URL(string: formUrlString)!
                    let (data, _) = try await URLSession.shared.data(from: formUrl)
                    
                    let formDto = try decoder.decode(FormDTO.self, from: data)
                    
                    return formDto
                }
            }
            
            for try await formDto in group {
                formDtos.append(formDto)
            }
        }
        
        return formDtos
    }
    
    @concurrent
    private func fetchVarities(from varities: [PokemonSpeciesDTO.VarietiesDTO], decoder: JSONDecoder) async throws -> [PokemonBasicDTO] {
        var varitiesDtos: [PokemonBasicDTO] = []
        
        guard !varities.isEmpty else { return [] }
        
        try await withThrowingTaskGroup(of: PokemonBasicDTO.self) { group in
            for varity in varities {
                group.addTask {
                    let pokemonUrl = URL(string: varity.pokemon.url)!
                    
                    let (data, _) = try await URLSession.shared.data(from: pokemonUrl)
                    let pokemonDto = try decoder.decode(PokemonBasicDTO.self, from: data)
                    
                    return pokemonDto
                }
            }
            
            for try await pokemonDto in group {
                varitiesDtos.append(pokemonDto)
            }
        }
        
        return varitiesDtos
    }
    
    nonisolated private func createModel(with dto: (basic: PokemonBasicDTO, species: PokemonSpeciesDTO, forms: [FormDTO])) -> [PokemonModel] {
        var pokemons: [PokemonModel] = []
        
        // 메인+폼 별 정보
        for formDto in dto.forms {
            let pokemon = PokemonModel(id: dto.basic.id,
                                       koreanName: dto.species.koreanName,
                                       classification: dto.species.koreanGenera,
                                       defaultSpriteUrl: dto.basic.defaultSpriteUrl,
                                       officialArtworkUrl: dto.basic.officialArtworkUrl,
                                       height: dto.basic.convertedHeight,
                                       weight: dto.basic.convertedWeight,
                                       gender: dto.species.gender,
                                       types: dto.basic.koreanTypes,
                                       flavorText: dto.species.flavorText,
                                       formName: formDto.koreanFormName
            )
            pokemons.append(pokemon)
            
        }
        
        return pokemons
    }
    
    nonisolated private func createModel(basic: PokemonBasicDTO, species: PokemonSpeciesDTO, forms: [FormDTO], varities: [PokemonBasicDTO]) -> [PokemonModel] {
        var pokemons: [PokemonModel] = []
        
        // 변형일 경우의 정보
        for (varity, form) in zip(varities, forms) {
            let pokemon = PokemonModel(id: basic.id,
                                       koreanName: varity.name,
                                       classification: species.koreanGenera,
                                       defaultSpriteUrl: varity.defaultSpriteUrl,
                                       officialArtworkUrl: varity.officialArtworkUrl,
                                       height: varity.convertedHeight,
                                       weight: varity.convertedWeight,
                                       gender: species.gender,
                                       types: varity.koreanTypes,
                                       flavorText: species.flavorText,
                                       formName: form.koreanFormName
            )
            pokemons.append(pokemon)
        }
        
        return pokemons
    }
}
