//
//  PokemonDTO.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation

// MARK: pokemon/{id}
struct PokemonBasicDTO: Decodable {
    let id: Int
    let height: Int
    let weight: Int
    let sprites: SpriteDTO
    let types: [TypeEntryDTO]
    let species: LinkDTO
    let forms: [LinkDTO] // 폼 정보의 주소들
    
    struct SpriteDTO: Decodable {
        let frontDefault: String
        let other: OtherDTO
    }
    
    struct TypeEntryDTO: Decodable {
        let slot: Int
        let type: LinkDTO
    }
    
    struct OtherDTO: Decodable {
        let officialArtwork: ArtworkDTO
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }

    struct ArtworkDTO: Decodable {
        let frontDefault: String
    }
}

// MARK: pokemon-species/{id}
struct PokemonSpeciesDTO: Decodable {
    let names: [NameDTO] // 한국어 이름 위치
    let genera: [GenusDTO] // 한국어 분류 위치
    let flavorTextEntries: [FlavorTextDTO]? // 한국어 설명 위치
    let genderRate: Int // 성별 판별 숫자
    
    struct GenusDTO: Decodable {
        let genus: String
        let language: LinkDTO
    }
}

struct NameDTO: Decodable {
    let name: String
    let language: LinkDTO // language.name == "ko" 인지 확인
}

struct FlavorTextDTO: Decodable {
    let flavorText: String
    let language: LinkDTO // language.name == "ko" 인지 확인
}

// 특정 정보에 대한 url을 담고 있는 DTO(예: species의 경우 name: "이상해씨", url: "species에 대한 url"
struct LinkDTO: Decodable {
    let name: String
    let url: String
}

