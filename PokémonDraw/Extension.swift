//
//  Extension.swift
//  PokémonDraw
//
//  Created by picnic on 2/6/26.
//

import Foundation

extension String {
    /// URL 문자열에서 마지막 경로의 숫자를 추출
    nonisolated var extractId: Int? {
        // 1. "/"로 쪼개기
        guard let lastPart = self.split(separator: "/").last,
              let id = Int(lastPart) else {
            return nil
        }
        
        return id
    }
}
