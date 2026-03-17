//
//  ImageCache.swift
//  PokémonDraw
//
//  Created by picnic on 2/28/26.
//

import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: [URL: UIImage] = [:]
    
    func image(for url: URL) -> UIImage? {
        return cache[url]
    }
    
    func insert(_ image: UIImage, for url: URL) {
        cache[url] = image
    }
}
