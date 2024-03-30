//
//  SegmentModel.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import Foundation

class Segment: Identifiable, Equatable, ObservableObject {
    
    init(rowIndex: Int, duration: Double, durationPreceeding: Double, dynamic: Bar.Dynamic?, note: Note?, id: UUID = UUID(), isSelected: Bool = false) {
        self.rowIndex = rowIndex
        self.duration = duration
        self.durationPreceeding = durationPreceeding
        self.dynamic = dynamic
        self.note = note
        self.id = id
        self.isSelected = isSelected
    }
    
    @Published var rowIndex: Int
    
    let duration: Double
    let durationPreceeding: Double
    let dynamic: Bar.Dynamic?
    let note: Note?
    var isSelected: Bool
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Segment, rhs: Segment) -> Bool {
        lhs.id == rhs.id
    }
    
    func increasePitch() {
        note?.increasePitch()
        rowIndex += 1
    }
    
    func toggleIsSelected() {
        self.isSelected.toggle()
    }
}
