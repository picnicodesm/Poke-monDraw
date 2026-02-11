//
//  PokemonModel.swift
//  PokémonDraw
//
//  Created by picnic on 2/5/26.
//

import Foundation


nonisolated
struct PokemonModel: Identifiable {
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
         formName: String) {
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
    
    init(basic: PokemonBasicDTO, species: PokemonSpeciesDTO, form: FormDTO) {
        // id, koreanFormName
        let filteredFormNames = form.formNames.filter { $0.language.name == "ko" }
        let koreanFormName = filteredFormNames.isEmpty ? form.formName : filteredFormNames.first!.name
        
        let uniqueId = koreanFormName.isEmpty ? "i\(basic.id)f000n\(form.pokemon.name)" : "i\(basic.id)f\(form.id)n\(form.pokemon.name)"
        
        // pokemon name in Korean
        let koreanName = species.names.filter { $0.language.name == "ko" }.first?.name ?? species.name
        
        // pokemon genera in Korean
        let koFiltered = species.genera.filter { $0.language.name == "ko" }
        let enFiltered = species.genera.filter { $0.language.name == "en" }
        let koreanGenera = (koFiltered.isEmpty && enFiltered.isEmpty) ? "알 수 없음" : koFiltered.isEmpty ? enFiltered.first!.genus : koFiltered.first!.genus
        
        // default+officialArtWork sprite url
        let spriteUrlInForm = form.sprites?.frontDefault ?? ""
        let officialArtworkUrl = basic.sprites.other?.officialArtwork?.frontDefault ?? ""
        
        // gender
        let gender: String = switch species.genderRate {
        case -1: "불명"
        case 1...7: "수컷 / 암컷"
        case 0: "수컷"
        default: "암컷"
        }
        
        // type
        let koreanTypes: [String] = basic.types.map {
            PokemonType(rawValue: $0.type.name)?.koreanType ?? "알 수 없음"
        }
        
        // flavorText
        let koFilteredInFlavorTextEntries = species.flavorTextEntries.filter { $0.language.name == "ko" }
        let enFilteredInFlavorTextEntries = species.flavorTextEntries.filter { $0.language.name == "en" }
        let flavorText = (koFilteredInFlavorTextEntries.isEmpty && enFilteredInFlavorTextEntries.isEmpty) ? "설명 없음" : koFilteredInFlavorTextEntries.isEmpty ? enFilteredInFlavorTextEntries.first!.flavorText : koFilteredInFlavorTextEntries.first!.flavorText
        
        self.id = uniqueId
        self.pokedexNumber = basic.id
        self.koreanName = koreanName
        self.classification = koreanGenera
        self.defaultSpriteUrl = spriteUrlInForm
        self.officialArtworkUrl = form.id == basic.id ? officialArtworkUrl : ""
        self.height = Double(basic.height) / 10
        self.weight = Double(basic.weight) / 10
        self.gender = gender
        self.types = koreanTypes
        self.flavorText = flavorText
        self.formName = koreanFormName
    }
    
    init(basic: PokemonBasicDTO, species: PokemonSpeciesDTO, form: FormDTO, varity: PokemonBasicDTO) {
        // id, koreanFormName
        let filteredFormNames = form.formNames.filter { $0.language.name == "ko" }
        let koreanFormName = filteredFormNames.isEmpty ? form.formName : filteredFormNames.first!.name
        
        let uniqueId = "i\(basic.id)f\(form.id)n\(form.pokemon.name)"

        // pokemon genera in Korean
        let koFiltered = species.genera.filter { $0.language.name == "ko" }
        let enFiltered = species.genera.filter { $0.language.name == "en" }
        let koreanGenera = (koFiltered.isEmpty && enFiltered.isEmpty) ? "알 수 없음" : koFiltered.isEmpty ? enFiltered.first!.genus : koFiltered.first!.genus
        
        // default+officialArtWork sprite url
        let spriteUrlInForm = form.sprites?.frontDefault ?? ""
        let officialArtworkUrlOfVarity = varity.sprites.other?.officialArtwork?.frontDefault ?? ""
        
        // gender
        let gender: String = switch species.genderRate {
        case -1: "불명"
        case 1...7: "수컷 / 암컷"
        case 0: "수컷"
        default: "암컷"
        }
        
        // type
        let koreanTypes: [String] = varity.types.map {
            PokemonType(rawValue: $0.type.name)?.koreanType ?? "알 수 없음"
        }
        
        // flavorText
        let koFilteredInFlavorTextEntries = species.flavorTextEntries.filter { $0.language.name == "ko" }
        let enFilteredInFlavorTextEntries = species.flavorTextEntries.filter { $0.language.name == "en" }
        let flavorText = (koFilteredInFlavorTextEntries.isEmpty && enFilteredInFlavorTextEntries.isEmpty) ? "설명 없음" : koFilteredInFlavorTextEntries.isEmpty ? enFilteredInFlavorTextEntries.first!.flavorText : koFilteredInFlavorTextEntries.first!.flavorText
        
        self.id = uniqueId
        self.pokedexNumber = basic.id
        self.koreanName = varity.name
        self.classification = koreanGenera
        self.defaultSpriteUrl = spriteUrlInForm
        self.officialArtworkUrl = officialArtworkUrlOfVarity
        self.height = Double(varity.height) / 10
        self.weight = Double(varity.weight) / 10
        self.gender = gender
        self.types = koreanTypes
        self.flavorText = flavorText
        self.formName = koreanFormName
    }
    
}

nonisolated
extension PokemonModel {
    var printString: String {
        return "id: \(id), name: \(koreanName), 성별: \(gender), height: \(height), weight: \(weight), formName: \(formName), types: \(types)"
    }

    static let mock = [PokémonDraw.PokemonModel(id: "6_default", pokedexNumber: 6, koreanName: "리자몽", classification: "화염포켓몬", defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png", officialArtworkUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png", height: 1.7, weight: 90.5, gender: "수컷 / 암컷", types: ["불꽃", "비행"], flavorText: "입에서 작렬하는 불꽃을\n토해낼 때 꼬리의 끝이\n더욱 붉고 격렬하게 타오른다.", formName: ""), PokémonDraw.PokemonModel(id: "6_gmax", pokedexNumber: 6, koreanName: "charizard-gmax", classification: "화염포켓몬", defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/10196.png", officialArtworkUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10196.png", height: 28.0, weight: 1000.0, gender: "수컷 / 암컷", types: ["불꽃", "비행"], flavorText: "입에서 작렬하는 불꽃을\n토해낼 때 꼬리의 끝이\n더욱 붉고 격렬하게 타오른다.", formName: "gmax"), PokémonDraw.PokemonModel(id: "6_메가리자몽Y", pokedexNumber: 6, koreanName: "charizard-mega-x", classification: "화염포켓몬", defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/10034.png", officialArtworkUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10034.png", height: 1.7, weight: 110.5, gender: "수컷 / 암컷", types: ["불꽃", "드래곤"], flavorText: "입에서 작렬하는 불꽃을\n토해낼 때 꼬리의 끝이\n더욱 붉고 격렬하게 타오른다.", formName: "메가리자몽Y"), PokémonDraw.PokemonModel(id: "6_메가리자몽X", pokedexNumber: 6, koreanName: "charizard-mega-y", classification: "화염포켓몬", defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/10035.png", officialArtworkUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10035.png", height: 1.7, weight: 100.5, gender: "수컷 / 암컷", types: ["불꽃", "비행"], flavorText: "입에서 작렬하는 불꽃을\n토해낼 때 꼬리의 끝이\n더욱 붉고 격렬하게 타오른다.", formName: "메가리자몽X")]
}
