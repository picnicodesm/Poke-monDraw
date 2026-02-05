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
    var height: Double // m 단위 변환 후 저장
    var weight: Double // kg 단위 변환 후 저장
    var genderStatus: String // "수컷", "암컷", "성별 없음"
    
    // 4. 한국어 텍스트 정보
    var types: [String]
    var flavorText: String
    
    // 5. 멀티 폼 정보 (간단하게 이름과 이미지 URL 쌍으로 저장)
    var forms: [PokemonFormInfo]
    
    init(id: Int,
         koreanName: String,
         classification: String,
         defaultSpriteUrl: String,
         officialArtworkUrl: String,
         height: Double,
         weight: Double,
         genderStatus: String,
         types: [String],
         flavorText: String,
         forms: [PokemonFormInfo]
    ) {
        self.id = id
        self.koreanName = koreanName
        self.classification = classification
        self.defaultSpriteUrl = defaultSpriteUrl
        self.officialArtworkUrl = officialArtworkUrl
        self.height = height
        self.weight = weight
        self.genderStatus = genderStatus
        self.types = types
        self.flavorText = flavorText
        self.forms = forms
    }
}

// 여러 폼을 저장하기 위한 보조 구조체
struct PokemonFormInfo: Codable {
    var name: String
    var imageUrl: String
}
