//
//  GlobalDataService.swift
//  Intervision
//
//  Created by Reuben on 02/05/2024.
//

import Foundation
import SwiftUI

public class GlobalDataService {
    
}

extension Int {
    func trueModulo(_ modulus: Int) -> Int {
        return (self % modulus + modulus) % modulus
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
