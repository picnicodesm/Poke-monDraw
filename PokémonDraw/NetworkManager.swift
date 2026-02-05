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
        var results: [PokemonModel] = []
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        try await withThrowingTaskGroup(of: [PokemonModel].self) { group in
            for i in 1...1025 {
                group.addTask {
                    // 1. default url에서 PokemonBasicDTO 얻기
                    let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(i)/")!
                    
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let dto = try decoder.decode(PokemonBasicDTO.self, from: data)
                    
                    
                    
                    // 2. species url에서 PokemonSpeciesDTO 얻기
                    let speciesUrl = URL(string: dto.speciesUrl)!
                    let (speciesData, _) = try await URLSession.shared.data(from: speciesUrl)
                    let speciesDto = try decoder.decode(PokemonSpeciesDTO.self, from: speciesData)
                    
                    
                    
                    // 3. 폼에 대한 정보 얻기
                    var formDtos: [FormDTO] = []
                    
                    try await withThrowingTaskGroup(of: FormDTO.self) { group in
                        for formUrlString in dto.formsUrls {
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
                    
                    
                    
                    
                    // 4. species의 isDefault가 false인게 있다면 해당 변형에 대해 얻기
                    let varities = speciesDto.nonDefaultVarities
                    var varitiesDtos: [PokemonBasicDTO] = []
                    
                    if !varities.isEmpty {
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
                    }
                    
                    
                    
                    // 5. 변형별 폼 정보 얻기
                    var varityFormDtos: [FormDTO] = []
                    // 변형 하나에는 폼이 하나. 폼의 이름은 없을수도, 한국어가 없을 수도, 있을 수도 있음
                    if !varitiesDtos.isEmpty {
                        try await withThrowingTaskGroup(of: FormDTO.self) { group in
                            for varity in varitiesDtos {
                                guard let formUrlString = varity.formsUrls.first else {
                                    print(varity.name)
                                    continue
                                }
                                group.addTask {
                                    let formUrl = URL(string: formUrlString)!
                                    let (data, _) = try await URLSession.shared.data(from: formUrl)
                                    
                                    let formDto = try decoder.decode(FormDTO.self, from: data)
                                    
                                    return formDto
                                }
                            }
                            
                            for try await formDto in group {
                                varityFormDtos.append(formDto)
                            }
                        }
                    }
                    
                    
                    // 리턴할 정보
                    var pokemons: [PokemonModel] = []
                    
                    // 메인+폼 별 정보
                    for (index, formDto) in formDtos.enumerated() {
                        let pokemon = PokemonModel(id: dto.id,
                                                   koreanName: speciesDto.koreanName,
                                                   classification: speciesDto.koreanGenera,
                                                   defaultSpriteUrl: dto.defaultSpriteUrl,
                                                   officialArtworkUrl: dto.officialArtworkUrl,
                                                   height: dto.convertedHeight,
                                                   weight: dto.convertedWeight,
                                                   gender: speciesDto.gender,
                                                   types: dto.koreanTypes,
                                                   flavorText: speciesDto.flavorText,
                                                   formName: formDto.koreanFormName
                        )
                        pokemons.append(pokemon)
                        
                    }
                    
                    
                    // 변형일 경우의 정보
                    for (varityDto, formDto) in zip(varitiesDtos, varityFormDtos) {
                        let pokemon = PokemonModel(id: dto.id,
                                                   koreanName: varityDto.name,
                                                   classification: speciesDto.koreanGenera,
                                                   defaultSpriteUrl: varityDto.defaultSpriteUrl,
                                                   officialArtworkUrl: varityDto.officialArtworkUrl,
                                                   height: varityDto.convertedHeight,
                                                   weight: varityDto.convertedWeight,
                                                   gender: speciesDto.gender,
                                                   types: varityDto.koreanTypes,
                                                   flavorText: speciesDto.flavorText,
                                                   formName: formDto.koreanFormName
                        )
                        pokemons.append(pokemon)
                    }
                    
                    return pokemons
                }
            }
            
            for try await pokemons in group {
                results += pokemons
            }
        }
        
        print(results.sorted(by: { $0.id < $1.id }).map { $0.printString }.joined(separator: "\n"))
        
    }
}




//                    // 메인 포켓몬 정보
//                    let pokemon = PokemonModel(id: dto.id,
//                                               koreanName: speciesDto.koreanName,
//                                               classification: speciesDto.koreanGenera,
//                                               defaultSpriteUrl: dto.defaultSpriteUrl,
//                                               officialArtworkUrl: dto.officialArtworkUrl,
//                                               height: dto.convertedHeight,
//                                               weight: dto.convertedWeight,
//                                               gender: speciesDto.gender,
//                                               types: dto.koreanTypes,
//                                               flavorText: speciesDto.flavorText,
//                                               formName: formDtos.first!.koreanFormName
//                    )
//                    pokemons.append(pokemon)
//
//                    // 다른 폼일 경우의 정보
//                    if formDtos.count > 1 {
//                        for i in 1..<formDtos.count {
//                            let formDto = formDtos[i]
//                            let pokemon = PokemonModel(id: dto.id,
//                                                       koreanName: speciesDto.koreanName,
//                                                       classification: speciesDto.koreanGenera,
//                                                       defaultSpriteUrl: formDto.spriteUrl,
//                                                       height: dto.convertedHeight,
//                                                       weight: dto.convertedWeight,
//                                                       gender: speciesDto.gender,
//                                                       types: dto.koreanTypes,
//                                                       flavorText: speciesDto.flavorText,
//                                                       formName: formDto.koreanFormName
//                            )
//
//                            pokemons.append(pokemon)
//                        }
//                    }
