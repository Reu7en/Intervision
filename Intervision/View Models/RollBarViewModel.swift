//
//  RollBarViewModel.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import Foundation

class RollBarViewModel: ObservableObject {
    
    @Published var segments: [[Segment]] = []
    
    let bars: [Bar]
    let octaves: Int
    
    init(bars: [Bar], octaves: Int) {
        self.bars = bars
        self.octaves = octaves
        
        calculateSegments()
    }
    
    private func calculateSegments() {
        for bar in bars {
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
            
            segments.append(barSegments)
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
}

extension RollBarViewModel {
    struct Segment {
        let rowIndex: Int
        let duration: Double
        let durationPreceeding: Double
    }
}
