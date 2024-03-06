//
//  RollViewModel.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import Foundation
import SwiftUI

class RollViewModel: ObservableObject {
    
    @Published var score: Score?
    @Published var parts: [Part]? {
        didSet {
            calculateSegments()
        }
    }
    
    @Published var segments: [[[[Segment]]]]?
    
    @Published var octaves: Int = 9
    @Published var harmonicIntervalLinesType: IntervalLinesViewModel.IntervalLinesType = .none
    @Published var showMelodicIntervalLines: Bool = false
    
    static let partSegmentColors: [Color] = [
        Color(red: 1, green: 0, blue: 0),
        Color(red: 0, green: 1, blue: 0),
        Color(red: 0, green: 0, blue: 1),
        Color(red: 1, green: 1, blue: 0),
        Color(red: 1, green: 0, blue: 1),
        Color(red: 0, green: 1, blue: 1),
        Color(red: 1, green: 128/255, blue: 0),
        Color(red: 0, green: 128/255, blue: 128/255),
        Color(red: 128/255, green: 0, blue: 1),
        Color(red: 1, green: 128/255, blue: 1),
        Color(red: 1, green: 1, blue: 1),
        Color(red: 128/255, green: 128/255, blue: 128/255)
    ]
    
    static let harmonicIntervalLineColors: [Color] = partSegmentColors
    static let melodicIntervalLineColors: [Color] = partSegmentColors
    
    func addAllParts() {
        guard let score = score, let parts = score.parts else { return }
        self.parts = parts
    }

    func removeAllParts() {
        self.parts = nil
    }

    func addPart(_ part: Part) {
        var updatedParts = self.parts ?? []
        updatedParts.append(part)
        self.parts = sortPartsBasedOnScoreOrder(updatedParts)
    }

    func removePart(_ part: Part) {
        guard var updatedParts = self.parts else { return }
        updatedParts.removeAll { $0.id == part.id }
        self.parts = sortPartsBasedOnScoreOrder(updatedParts)
    }
    
    func sortPartsBasedOnScoreOrder(_ parts: [Part]) -> [Part] {
        guard let scoreParts = score?.parts else { return parts }
        
        var sortedParts = [Part]()
        for scorePart in scoreParts {
            if let matchingPart = parts.first(where: { $0.id == scorePart.id }) {
                sortedParts.append(matchingPart)
            }
        }
        
        return sortedParts
    }
    
    func calculateSegments() {
        guard let scoreParts = self.parts else { self.segments = nil; return }
        self.segments = []
        
        for part in scoreParts {
            var partSegments: [[[Segment]]] = []
            
            for staveBars in part.bars {
                var staveSegments: [[Segment]] = []
                
                for bar in staveBars {
                    var barSegments: [Segment] = []
                    let timeSignature = bar.timeSignature
                    var barDuration: Double = -1
                    
                    switch timeSignature {
                    case .common:
                        barDuration = 1.0
                    case .cut:
                        barDuration = 1.0
                    case .custom(let beats, let noteValue):
                        barDuration = Double(beats) / Double(noteValue)
                    }
                    
                    var timeLeft = barDuration
                    
                    for chord in bar.chords {
                        if let firstNote = chord.notes.first {
                            var chordDuration = firstNote.isDotted ? firstNote.duration.rawValue * 1.5 : firstNote.duration.rawValue
                            
                            if let timeModification = firstNote.timeModification {
                                switch timeModification {
                                case .custom(let actual, let normal):
                                    chordDuration /= (Double(actual) / Double(normal))
                                }
                            }
                            
                            for note in chord.notes {
                                if !note.isRest {
                                    if let rowIndex = calculateRowIndex(for: note) {
                                        var duration = note.isDotted ? note.duration.rawValue * 1.5 : note.duration.rawValue
                                        let durationPreceeding = barDuration - timeLeft
                                        
                                        if let timeModification = note.timeModification {
                                            switch timeModification {
                                            case .custom(let actual, let normal):
                                                duration /= (Double(actual) / Double(normal))
                                            }
                                        }
                                        
                                        barSegments.append(Segment(rowIndex: rowIndex, duration: duration, durationPreceeding: durationPreceeding))
                                    }
                                }
                            }
                            
                            timeLeft -= chordDuration
                        }
                    }
                    
                    staveSegments.append(barSegments)
                }
                
                partSegments.append(staveSegments)
            }
            
            self.segments?.append(partSegments)
        }
    }
    
    private func calculateRowIndex(for note: Note) -> Int? {
        if let pitch = note.pitch,
           let octave = note.octave {
            var rowIndex = 0
            
            let semitonesFromC = pitch.semitonesFromC()
            let octaveValue = octave.rawValue
            let rows = octaves * 12
            
            rowIndex = rows - 1 - (octaveValue * 12) - semitonesFromC
            
            if let accidental = note.accidental {
                rowIndex -= accidental.rawValue
            }
            
            return rowIndex
        } else { return nil }
    }
    
    static func getBeatData(bar: Bar) -> (beats: Int, noteValue: Int) {
        switch bar.timeSignature {
        case .common:
            return (4, 4)
        case .cut:
            return (2, 2)
        case .custom(let beats, let noteValue):
            return (beats, noteValue)
        }
    }
    
    func getSegmentColors() -> [Color] {
        var colors: [Color] = []
        
        if let score = self.score, let parts = score.parts, let viewParts = self.parts {
            for (partIndex, part) in parts.enumerated() {
                let segmentColor: Color
                if viewParts.contains(part) {
                    if partIndex < RollViewModel.partSegmentColors.count {
                        segmentColor = RollViewModel.partSegmentColors[partIndex]
                    } else {
                        segmentColor = Color.black
                    }
                    
                    colors.append(segmentColor)
                }
            }
        }
        
        return colors
    }
}
