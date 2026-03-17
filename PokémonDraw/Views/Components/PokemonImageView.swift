//
//  PokemonImageView.swift
//  PokémonDraw
//
//  Created by picnic on 2/28/26.
//

import SwiftUI

    struct PokemonImageView: View {
    let urlString: String
    
    @State private var uiImage: UIImage? = nil
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
            }
        }
        .task {
            guard uiImage == nil else {
                print("이미 이미지를 가지고 있는 PokemonImageView입니다.")
                return
            }
            
            isLoading = true
            defer { isLoading = false }
            
            do {
                if let fetchedImage = try await NetworkManager.shared.fetchImage(from: urlString) {
                    self.uiImage = fetchedImage
                }
            } catch {
                print("이미지 로드 실패 - url: \(urlString)")
            }
        }
        .onDisappear {
            uiImage = nil
        }
    }
}
