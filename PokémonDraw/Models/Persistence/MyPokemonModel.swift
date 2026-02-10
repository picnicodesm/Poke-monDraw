//
//  MyPokemonModel.swift
//  PokémonDraw
//
//  Created by picnic on 2/10/26.
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
    
    convenience init(from model: PokemonModel) {
        self.init(
            id: model.id,
            pokedexNumber: model.pokedexNumber,
            koreanName: model.koreanName,
            classification: model.classification,
            defaultSpriteUrl: model.defaultSpriteUrl,
            officialArtworkUrl: model.officialArtworkUrl,
            height: model.height,
            weight: model.weight,
            gender: model.gender,
            types: model.types,
            flavorText: model.flavorText,
            formName: model.formName
        )
    }
    
    var toStruct: PokemonModel {
        return PokemonModel(
            id: id,
            pokedexNumber: pokedexNumber,
            koreanName: koreanName,
            classification: classification,
            defaultSpriteUrl: defaultSpriteUrl,
            officialArtworkUrl: officialArtworkUrl,
            height: height,
            weight: weight,
            gender: gender,
            types: types,
            flavorText: flavorText,
            formName: formName
        )
    }
}
