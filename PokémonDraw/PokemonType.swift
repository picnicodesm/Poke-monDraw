//
//  PokemonType.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation

nonisolated
enum PokemonType: String {
    case normal, fighting, flying, poison, ground, rock
    case bug, ghost, steel, fire, water, grass
    case electric, psychic, ice, dragon, dark, fairy
    case stellar
    
    var koreanType: String {
        switch self {
        case .normal: "노말"
        case .fighting: "격투"
        case .flying: "비행"
        case .poison: "독"
        case .ground: "땅"
        case .rock: "바위"
        case .bug: "벌레"
        case .ghost: "고스트"
        case .steel: "강철"
        case .fire: "불꽃"
        case .water: "물"
        case .grass: "풀"
        case .electric: "전기"
        case .psychic: "에스퍼"
        case .ice: "얼음"
        case .dragon: "드래곤"
        case .dark: "악"
        case .fairy: "페어리"
        case .stellar: "스텔라"
        }
    }
}
