//
//  SegmentModel.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import Foundation

struct Segment: Identifiable, Equatable {
    let rowIndex: Int
    let duration: Double
    let durationPreceeding: Double
    let dynamic: Bar.Dynamic?
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Segment, rhs: Segment) -> Bool {
        lhs.id == rhs.id
    }
}
