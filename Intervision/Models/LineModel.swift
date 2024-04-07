//
//  LineModel.swift
//  Intervision
//
//  Created by Reuben on 05/03/2024.
//

import Foundation
import SwiftUI

struct Line: Identifiable, Equatable, Comparable {
    
    var startPoint: CGPoint
    var endPoint: CGPoint
    let color: Color
    let inversionType: InversionType?
    
    init(startPoint: CGPoint, endPoint: CGPoint, color: Color = .black, inversionType: InversionType? = nil, id: UUID = UUID()) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.color = color
        self.inversionType = inversionType
        self.id = id
    }
    
    var length: CGFloat {
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
    
    // Identifiable
    var id = UUID()
    
    // Equatable - checks for equal relevant properties rather than id
    static func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.startPoint == rhs.startPoint &&
               lhs.endPoint == rhs.endPoint &&
               lhs.color == rhs.color
    }
    
    // Comparable - sorts lines firstly by x position, and then by ascending length
    static func < (lhs: Line, rhs: Line) -> Bool {
        if lhs.startPoint.x != rhs.startPoint.x {
            return lhs.startPoint.x < rhs.startPoint.x
        } else {
            return abs(lhs.endPoint.y - lhs.startPoint.y) < abs(rhs.endPoint.y - rhs.startPoint.y)
        }
    }
}

extension Line {
    enum InversionType {
        case None
        case Inverted
        case Neither
    }
}
