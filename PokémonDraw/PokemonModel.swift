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
    // 1. 기본 식별 정보
    @Attribute(.unique) var id: Int
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
    
    init(id: Int,
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
    var id: Int
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
    
    init(id: Int,
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
    
    static let mock = PokemonModel(id: -1,
                                   koreanName: "mock 포켓몬",
                                   classification: "분류 없음",
                                   defaultSpriteUrl: "이미지 url.png",
                                   officialArtworkUrl: "오피셜 아트워크 url.png",
                                   height: 10,
                                   weight: 8,
                                   gender: "알 수 없음",
                                   types: ["타입 1", "타입 2"],
                                   flavorText: "포켓몬 설명",
                                   formName: "기본 폼"
    )
}
