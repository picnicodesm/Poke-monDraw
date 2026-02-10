//
//  Poke_monDrawApp.swift
//  PokémonDraw
//
//  Created by picnic on 2/4/26.
//

import SwiftUI
import SwiftData

@main
struct Poke_monDrawApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MyPokemon.self)
    }
}
