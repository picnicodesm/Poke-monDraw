//
//  PokemonModel.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation
import SwiftData

@Model
final class MyPokemon {
    // 1. 기본 식별 정보 (ex. "6_default", "6_mega-x", "351_sunny")
    @Attribute(.unique) var id: String
    
    var pokedexNumber: Int
    var koreanName: String
    var classification: String // 예: 씨앗포켓몬
    
    // 2. 이미지 정보
    var defaultSpriteUrl: String
    var officialArtworkUrl: String
    
    // 3. 신체 및 성별 정보
    var height: Double // m
    var weight: Double // kg
    var gender: Int // -1: 없음, 0: 둘 다 가능, 1: 수컷, 2: 암컷
    
    // 4. 한국어 텍스트 정보
    var types: [String]
    var flavorText: String
    
    // 5. 멀티 폼 정보 (간단하게 이름과 이미지 URL 쌍으로 저장)
    var formName: String
    
    init(id: String,
         pokedexNumber: Int,
         koreanName: String,
         classification: String,
         defaultSpriteUrl: String,
         officialArtworkUrl: String,
         height: Double,
         weight: Double,
         gender: Int,
         types: [String],
         flavorText: String,
         formName: String
    ) {
        self.id = id
        self.pokedexNumber = pokedexNumber
        self.koreanName = koreanName
        self.classification = classification
        self.defaultSpriteUrl = defaultSpriteUrl
        self.officialArtworkUrl = officialArtworkUrl
        self.height = height
        self.weight = weight
        self.gender = gender
        self.types = types
        self.flavorText = flavorText
        self.formName = formName
    }
}

nonisolated
struct PokemonModel {
    var id: String
 
    var pokedexNumber: Int
    var koreanName: String
    var classification: String // 예: 씨앗포켓몬
    
    // 2. 이미지 정보
    var defaultSpriteUrl: String
    var officialArtworkUrl: String
    
    // 3. 신체 및 성별 정보
    var height: Double // m
    var weight: Double // kg
    var gender: String
    
    // 4. 한국어 텍스트 정보
    var types: [String]
    var flavorText: String
    
    // 5. 멀티 폼 정보 (간단하게 이름과 이미지 URL 쌍으로 저장)
    var formName: String
    
    init(id: String,
         pokedexNumber: Int,
         koreanName: String,
         classification: String,
         defaultSpriteUrl: String,
         officialArtworkUrl: String,
         height: Double,
         weight: Double,
         gender: String,
         types: [String],
         flavorText: String,
         formName: String
    ) {
        self.id = id
        self.pokedexNumber = pokedexNumber
        self.koreanName = koreanName
        self.classification = classification
        self.defaultSpriteUrl = defaultSpriteUrl
        self.officialArtworkUrl = officialArtworkUrl
        self.height = height
        self.weight = weight
        self.gender = gender
        self.types = types
        self.flavorText = flavorText
        self.formName = formName
    }
}

nonisolated
extension PokemonModel {
    var printString: String {
        return "id: \(id), name: \(koreanName), 성별: \(gender), height: \(height), weight: \(weight), formName: \(formName), types: \(types)"
    }
    
    static let mock = [PokémonDraw.PokemonModel(id: "6_default", pokedexNumber: 6, koreanName: "리자몽", classification: "화염포켓몬", defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png", officialArtworkUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png", height: 1.7, weight: 90.5, gender: "수컷 / 암컷", types: ["불꽃", "비행"], flavorText: "입에서 작렬하는 불꽃을\n토해낼 때 꼬리의 끝이\n더욱 붉고 격렬하게 타오른다.", formName: ""), PokémonDraw.PokemonModel(id: "6_gmax", pokedexNumber: 6, koreanName: "charizard-gmax", classification: "화염포켓몬", defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/10196.png", officialArtworkUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10196.png", height: 28.0, weight: 1000.0, gender: "수컷 / 암컷", types: ["불꽃", "비행"], flavorText: "입에서 작렬하는 불꽃을\n토해낼 때 꼬리의 끝이\n더욱 붉고 격렬하게 타오른다.", formName: "gmax"), PokémonDraw.PokemonModel(id: "6_메가리자몽Y", pokedexNumber: 6, koreanName: "charizard-mega-x", classification: "화염포켓몬", defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/10034.png", officialArtworkUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10034.png", height: 1.7, weight: 110.5, gender: "수컷 / 암컷", types: ["불꽃", "드래곤"], flavorText: "입에서 작렬하는 불꽃을\n토해낼 때 꼬리의 끝이\n더욱 붉고 격렬하게 타오른다.", formName: "메가리자몽Y"), PokémonDraw.PokemonModel(id: "6_메가리자몽X", pokedexNumber: 6, koreanName: "charizard-mega-y", classification: "화염포켓몬", defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/10035.png", officialArtworkUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10035.png", height: 1.7, weight: 100.5, gender: "수컷 / 암컷", types: ["불꽃", "비행"], flavorText: "입에서 작렬하는 불꽃을\n토해낼 때 꼬리의 끝이\n더욱 붉고 격렬하게 타오른다.", formName: "메가리자몽X")]
}
