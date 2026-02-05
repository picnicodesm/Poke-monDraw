//
//  ContentView.swift
//  PokémonDraw
//
//  Created by picnic on 2/4/26.
//

import SwiftUI

struct ContentView: View {
    let nm = NetworkManager()
    @State private var text = "Good"
    
    var body: some View {
        VStack(spacing: 30) {
            Text(text)
                .padding()
            
            Button("fetch") {
                text = "fetching..."
                Task {
                    do {
                        try await nm.fetchPokemon()
                        text = "Good"
                    } catch {
                        text = "Failed"
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
