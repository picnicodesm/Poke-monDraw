//
//  PokemonDTO.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation


// MARK: - pokemon/{id}
nonisolated
struct PokemonBasicDTO: Decodable {
    
    let id: Int
    let name: String
    let species: LinkDTO
    let forms: [LinkDTO] // 폼 정보의 주소들
    let height: Int
    let weight: Int
    let sprites: SpriteDTO
    let types: [TypeEntryDTO]
    
    struct SpriteDTO: Decodable {
        let frontDefault: String?
        let other: OtherDTO?
    }
    
    struct TypeEntryDTO: Decodable {
        let slot: Int
        let type: LinkDTO
    }
    
    struct OtherDTO: Decodable {
        let officialArtwork: ArtworkDTO?
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }
    
    struct ArtworkDTO: Decodable {
        let frontDefault: String?
    }
}

// MARK: - pokemon-species/{id}
nonisolated
struct PokemonSpeciesDTO: Decodable {
    
    let name: String
    let names: [NameDTO]
    let genera: [GenusDTO] // "classification" in Model
    let flavorTextEntries: [FlavorTextDTO] // 한국어 설명 위치
    let varieties: [VarietiesDTO]
    let genderRate: Int // 1~7: both, 8: 암컷, 0: 수컷, -1: 성별 없음
    
    struct GenusDTO: Decodable {
        let genus: String
        let language: LinkDTO
    }
    
    struct FlavorTextDTO: Decodable {
        let flavorText: String
        let language: LinkDTO
    }
    
    struct VarietiesDTO: Decodable {
        let isDefault: Bool
        let pokemon: LinkDTO // url은 기본 basicURL을 가짐. 이 곳에서 기본 정보, sprites 등 획득 가능
    }
}

// MARK: - pokemon-form/{id}/
nonisolated
struct FormDTO: Decodable {
    
    let id: Int
    let pokemon: LinkDTO
    let formName: String
    let formNames: [NameDTO]
    let sprites: SpritesDTO?
    
    struct SpritesDTO: Decodable {
        let frontDefault: String?
    }
}


// MARK: - Common DTO
nonisolated
struct NameDTO: Decodable {
    let name: String
    let language: LinkDTO
}

// 특정 정보에 대한 url을 담고 있는 DTO(예: species의 경우 name: "이상해씨", url: "species에 대한 url"
nonisolated
struct LinkDTO: Decodable {
    let name: String
    let url: String
}

