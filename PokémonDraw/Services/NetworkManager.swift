//
//  NetworkManager.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation

actor NetworkManager {
    static let shared = NetworkManager()

    private init() { }
    
    @concurrent
    func fetchRandomPokemon() async throws -> [PokemonModel] {
        let randomNumber = Int.random(in: 1...1025)
        let pokemon = try await fetchPokemon(id: randomNumber)
        
        return pokemon
    }
    
    @concurrent
    func fetchPokemonBatch(from startId: Int, to endId: Int) async throws -> [PokemonModel] {
        var results: [PokemonModel] = []
        let decoder = JSONDecoder()
        
        try await withThrowingTaskGroup(of: [PokemonModel].self) { group in
            for id in startId...endId {
                guard id <= 1025 else { continue }
                
                group.addTask {
                    try Task.checkCancellation()
                    return try await self.fetchPokemon(id: id, decoder: decoder)
                }
            }
            
            for try await pokemonArr in group {
                try Task.checkCancellation()
                results += pokemonArr
            }
        }
        
        return results
    }
}

extension NetworkManager {
    
    @concurrent
    private func fetchPokemon(id: Int, decoder: JSONDecoder = JSONDecoder()) async throws -> [PokemonModel] {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        try Task.checkCancellation()
        // 1. default url에서 PokemonBasicDTO 얻기
        let dto = try await self.fetchPokemon(for: id, decoder: decoder)
        
        // 2. species url에서 PokemonSpeciesDTO 얻기
        let speciesDto = try await self.fetchPokemonSpecies(from: dto.species.url, decoder: decoder)
        
        
        try Task.checkCancellation()
        // 3. 폼에 대한 정보 얻기
        async let formDtos = self.fetchForms(from: dto.forms.map { $0.url }, decoder: decoder)
        
        // 4. species의 isDefault가 false인게 있다면 해당 변형에 대해 얻기
        let nonDefaultVarieties = speciesDto.varieties.filter { !$0.isDefault }
        async let varietiesDtos = self.fetchVarieties(from: nonDefaultVarieties, decoder: decoder)
        
        try Task.checkCancellation()
        // 5. 변형별 폼 정보 얻기
        let varityFormDtos = try await self.fetchForms(from: try await varietiesDtos, decoder: decoder)
        
        // 리턴할 정보
        var pokemonArr: [PokemonModel] = []
        pokemonArr += self.createModel(with: (dto, speciesDto, try await formDtos))
        pokemonArr += self.createModel(basic: dto, species: speciesDto, forms: varityFormDtos, varieties: try await varietiesDtos)
        
        return pokemonArr.sorted { $0.id < $1.id }
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
                guard let formUrlString = dto.forms.map({ $0.url }).first else { continue }
                
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
    private func fetchVarieties(from varieties: [PokemonSpeciesDTO.VarietiesDTO], decoder: JSONDecoder) async throws -> [PokemonBasicDTO] {
        var varietiesDtos: [PokemonBasicDTO] = []
        
        guard !varieties.isEmpty else { return [] }
        
        try await withThrowingTaskGroup(of: PokemonBasicDTO.self) { group in
            for varity in varieties {
                group.addTask {
                    let pokemonUrl = URL(string: varity.pokemon.url)!
                    let (data, _) = try await URLSession.shared.data(from: pokemonUrl)
                    let pokemonDto = try decoder.decode(PokemonBasicDTO.self, from: data)
                    
                    return pokemonDto
                }
            }
            
            for try await pokemonDto in group {
                varietiesDtos.append(pokemonDto)
            }
        }
        
        return varietiesDtos
    }
    
    nonisolated private func createModel(with dto: (basic: PokemonBasicDTO, species: PokemonSpeciesDTO, forms: [FormDTO])) -> [PokemonModel] {
        var pokemonArr: [PokemonModel] = []
        
        // 메인+폼 별 정보
        for formDto in dto.forms {
            let pokemon = PokemonModel(basic: dto.basic, species: dto.species, form: formDto)
            pokemonArr.append(pokemon)
            
        }
        
        return pokemonArr
    }
    
    nonisolated private func createModel(basic: PokemonBasicDTO, species: PokemonSpeciesDTO, forms: [FormDTO], varieties: [PokemonBasicDTO]) -> [PokemonModel] {
        var pokemonArr: [PokemonModel] = []
        
        // 변형일 경우의 정보
        for (varity, form) in zip(varieties.sorted { $0.id < $1.id }, forms.sorted { $0.pokemon.url.extractId! < $1.pokemon.url.extractId! }) {
            let pokemon = PokemonModel(basic: basic, species: species, form: form, varity: varity)
            pokemonArr.append(pokemon)
        }
        
        return pokemonArr
    }
}
