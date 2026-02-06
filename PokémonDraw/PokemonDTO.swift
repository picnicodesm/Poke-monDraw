//
//  PokemonDTO.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation


// MARK: - pokemon/{id}
struct PokemonBasicDTO: nonisolated Decodable {
    
    private let species: LinkDTO
    private let forms: [LinkDTO] // 폼 정보의 주소들
    private let height: Int
    private let weight: Int
    private let sprites: SpriteDTO
    private let types: [TypeEntryDTO]
    
    let id: Int
    let name: String
}

nonisolated
extension PokemonBasicDTO {
    
    var speciesUrl: String { species.url }
    var formsUrls: [String] { forms.map { $0.url } }
    var defaultSpriteUrl: String { sprites.frontDefault ?? "" }
    var officialArtworkUrl: String { sprites.other?.officialArtwork?.frontDefault ?? "" }
    var koreanTypes: [String] { types.map { PokemonType(rawValue: $0.type.name)?.koreanType ?? "알 수 없음" } }
    var convertedHeight: Double { Double(height) / 10 }
    var convertedWeight: Double { Double(weight) / 10 }
    
    private struct SpriteDTO: Decodable {
        let frontDefault: String?
        let other: OtherDTO?
    }
    
    private struct TypeEntryDTO: Decodable {
        let slot: Int
        let type: LinkDTO
    }
    
    private struct OtherDTO: Decodable {
        let officialArtwork: ArtworkDTO?
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }

    private struct ArtworkDTO: Decodable {
        let frontDefault: String?
    }
}

// MARK: - pokemon-species/{id}
struct PokemonSpeciesDTO: nonisolated Decodable {
    
    private let name: String
    private let names: [NameDTO]
    private let genera: [GenusDTO] // "classification" in Model
    private let flavorTextEntries: [FlavorTextDTO] // 한국어 설명 위치
    private let varieties: [VarietiesDTO]
    private let genderRate: Int // 1~7: both, 8: 암컷, 0: 수컷, -1: 성별 없음
}

nonisolated
extension PokemonSpeciesDTO {
    
    var koreanName: String {
        names.filter { $0.language.name == "ko" }.first?.name ?? name
    }
    
    var koreanGenera: String {
        let koFiltered = genera.filter { $0.language.name == "ko" }
        let enFiltered = genera.filter { $0.language.name == "en" }
        
        return (koFiltered.isEmpty && enFiltered.isEmpty) ? "알 수 없음" : koFiltered.isEmpty ? enFiltered.first!.genus : koFiltered.first!.genus
    }
    
    var flavorText: String {
        let koFiltered = flavorTextEntries.filter { $0.language.name == "ko" }
        let enFiltered = flavorTextEntries.filter { $0.language.name == "en" }
        
        return (koFiltered.isEmpty && enFiltered.isEmpty) ? "알 수 없음" : koFiltered.isEmpty ? enFiltered.first!.flavorText : koFiltered.first!.flavorText
    }
    
    var nonDefaultVarities: [VarietiesDTO] {
        varieties.filter { !$0.isDefault }
    }
    
    var gender: String {
        if genderRate == -1 {
            return "불명"
        } else if (1...7).contains(genderRate) {
            return "수컷 / 암컷"
        } else if genderRate == 0 {
            return "수컷"
        } else {
            return "암컷"
        }
    }
    
    private struct GenusDTO: Decodable {
        let genus: String
        let language: LinkDTO
    }
    
    private struct FlavorTextDTO: Decodable {
        let flavorText: String
        let language: LinkDTO
    }
    
    struct VarietiesDTO: Decodable {
        let isDefault: Bool
        let pokemon: LinkDTO // url은 기본 basicURL을 가짐. 이 곳에서 기본 정보, sprites 등 획득 가능
    }
}

// MARK: - pokemon-form/{id}/
struct FormDTO: nonisolated Decodable {
    
    let id: Int
    private let pokemon: LinkDTO
    private let formName: String
    private let formNames: [NameDTO]
    private let sprites: SpritesDTO?
}

nonisolated
extension FormDTO {
    var koreanFormName: String {
        let filtered = formNames.filter { $0.language.name == "ko" }
        return filtered.isEmpty ? formName : filtered.first!.name
    }
    
    var spriteUrl: String {
        sprites?.frontDefault ?? ""
    }
    
    var pokemonId: Int {
        return pokemon.url.extractId!
    }
    
    private struct SpritesDTO: Decodable {
        let frontDefault: String?
    }
}


// MARK: - Common DTO
struct NameDTO: Decodable {
    let name: String
    let language: LinkDTO
}

// 특정 정보에 대한 url을 담고 있는 DTO(예: species의 경우 name: "이상해씨", url: "species에 대한 url"
struct LinkDTO: Decodable {
    let name: String
    let url: String
}

