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
    
    var duration: Double
    var durationPreceeding: Double
    let dynamic: Bar.Dynamic?
    let note: Note?
    var isSelected: Bool
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Segment, rhs: Segment) -> Bool {
        lhs.id == rhs.id
    }
    
    func increaseSemitone() {
        note?.increaseSemitone()
        self.rowIndex -= 1
    }
    
    func decreaseSemitone() {
        note?.decreaseSemitone()
        self.rowIndex += 1
    }
    
    func moveLeft(moveAmount: Double) {
        if self.durationPreceeding == 0 && self.duration == moveAmount {
            return
        } else if self.durationPreceeding == 0 {
            self.duration -= moveAmount
        } else {
            self.durationPreceeding -= moveAmount
        }
    }
    
    func moveRight(moveAmount: Double, barDuration: Double) {
        if self.durationPreceeding + self.duration == barDuration && self.duration == moveAmount {
            return
        } else if self.durationPreceeding + self.duration == barDuration {
            self.durationPreceeding += moveAmount
            self.duration -= moveAmount
        } else {
            self.durationPreceeding += moveAmount
        }
    }
    
    func toggleIsSelected() {
        self.isSelected.toggle()
    }
}
