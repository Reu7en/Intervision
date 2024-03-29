//
//  RollViewModel.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import Foundation
import SwiftUI

class RollViewModel: ObservableObject {
    
    @ObservedObject var scoreManager: ScoreManager
    
    @Published var parts: [Part]? {
        didSet {
            calculateSegments()
        }
    }
    
    @Published var segments: [[[[Segment]]]]?
    
    @Published var partGroups: [(String, [Part])] = []
    
    @Published var octaves: Int
    @Published var harmonicIntervalLinesType: IntervalLinesViewModel.IntervalLinesType
    @Published var showMelodicIntervalLines: Bool
    @Published var viewablePartSegmentColors: [Color]
    @Published var viewableHarmonicIntervalLineColors: [Color]
    @Published var viewableMelodicIntervalLineColors: [Color]
    @Published var viewableIntervals: [String]
    @Published var viewableMelodicLines: [Int] {
        didSet {
            print(self.viewableMelodicLines)
        }
    }
    @Published var showInvertedIntervals: Bool
    @Published var showZigZags: Bool
    
    init(
        scoreManager: ScoreManager,
        parts: [Part]? = nil,
        segments: [[[[Segment]]]]? = nil,
        octaves: Int = 9,
        harmonicIntervalLinesType: IntervalLinesViewModel.IntervalLinesType = .none,
        showMelodicIntervalLines: Bool = false,
        viewablePartSegmentColors: [Color] = partSegmentColors,
        viewableHarmonicIntervalLineColors: [Color] = harmonicIntervalLineColors,
        viewableMelodicIntervalLineColors: [Color] = melodicIntervalLineColors,
        viewableIntervals: [String] = intervals,
        viewableMelodicLines: [Int] = [],
        showInvertedIntervals: Bool = false,
        showZigZags: Bool = false
    ) {
        self.scoreManager = scoreManager
        self.parts = parts
        self.segments = segments
        self.octaves = octaves
        self.harmonicIntervalLinesType = harmonicIntervalLinesType
        self.showMelodicIntervalLines = showMelodicIntervalLines
        self.viewablePartSegmentColors = viewablePartSegmentColors
        self.viewableHarmonicIntervalLineColors = viewableHarmonicIntervalLineColors
        self.viewableMelodicIntervalLineColors = viewableMelodicIntervalLineColors
        self.viewableIntervals = viewableIntervals
        self.viewableMelodicLines = viewableMelodicLines
        self.showInvertedIntervals = showInvertedIntervals
        self.showZigZags = showZigZags
    }
    
    func initialisePartGroups() {
        guard let score = scoreManager.score, let parts = score.parts else { return }
        let group = ("All Parts", parts)
        
        partGroups = []
        partGroups.append(group)
    }
    
    func createPartGroup(groupName: String) {
        partGroups.append((groupName, []))
    }
    
    func deletePartGroup(groupName: String) {
        guard partGroups.count > 1 else { return }
        partGroups.removeAll { $0.0 == groupName }
    }
    
    func movePart(_ part: Part, from sourceGroup: String, to destinationGroup: String) {
        if let sourceIndex = partGroups.firstIndex(where: { $0.0 == sourceGroup }) {
            partGroups[sourceIndex].1.removeAll { $0.id == part.id }
            
            if partGroups[sourceIndex].1.isEmpty {
                partGroups.remove(at: sourceIndex)
            }
        }
        
        if let destinationIndex = partGroups.firstIndex(where: { $0.0 == destinationGroup }) {
            partGroups[destinationIndex].1.append(part)
        } else {
            partGroups.append((destinationGroup, [part]))
        }
    }
    
    func renamePartGroup(from oldName: String, to newName: String) {
        guard let index = partGroups.firstIndex(where: { $0.0 == oldName }) else { return }
        
        partGroups[index].0 = newName
    }
    
    func addAllParts() {
        guard let score = scoreManager.score, let parts = score.parts else { return }
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
        guard let scoreParts = scoreManager.score?.parts else { return parts }
        
        var sortedParts = [Part]()
        for scorePart in scoreParts {
            if let matchingPart = parts.first(where: { $0.id == scorePart.id }) {
                sortedParts.append(matchingPart)
            }
        }
        
        return sortedParts
    }
    
    func addViewableMelodicLine(_ index: Int) {
        if !viewableMelodicLines.contains(index) {
            viewableMelodicLines.append(index)
        }
    }
    
    func removeViewableMelodicLine(_ index: Int) {
        viewableMelodicLines.removeAll(where: { $0 == index })
    }
    
    func addAllViewableMelodicLines() {
        if let score = scoreManager.score,
           let scoreParts = score.parts,
           let parts = self.parts {
            for (index, _) in scoreParts.enumerated() {
                if parts.contains(scoreParts[index]) {
                    addViewableMelodicLine(index)
                }
            }
        }
    }
    
    func calculateSegments() {
        guard let scoreParts = self.parts else { self.segments = nil; return }
        self.segments = []
        
        for part in scoreParts {
            var partSegments: [[[Segment]]] = []
            var currentDynamics: [Bar.Dynamic?] = Array(repeating: nil, count: part.bars.first?.count ?? 0)
            
            for staveBars in part.bars {
                var staveSegments: [[Segment]] = []
                
                for (staveIndex, bar) in staveBars.enumerated() {
                    if let dynamics = bar.dynamics {
                        currentDynamics[staveIndex] = dynamics.first
                    }
                    
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
                                        
                                        barSegments.append(Segment(rowIndex: rowIndex, duration: duration, durationPreceeding: durationPreceeding, dynamic: currentDynamics[staveIndex]))
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
        
        if let score = self.scoreManager.score, let parts = score.parts, let viewParts = self.parts {
            for (partIndex, part) in parts.enumerated() {
                let segmentColor: Color
                if viewParts.contains(part) {
                    if partIndex < viewablePartSegmentColors.count {
                        segmentColor = viewablePartSegmentColors[partIndex]
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

extension RollViewModel {
    static let intervals: [String] = [
        "Minor 2nd", // 0
        "Major 2nd", // 1
        "Minor 3rd", // 2
        "Major 3rd", // 3
        "Perfect 4th", // 4
        "Tritone", // 5
        "Perfect 5th", // 6
        "Minor 6th", // 7
        "Major 6th", // 8
        "Minor 7th", // 9
        "Major 7th", // 10
        "Octave" // 11
    ]
    
    static let invertedIntervals: [String] = [
        "Minor 2nd/Major 7th", // 0
        "Major 2nd/Minor 7th", // 1
        "Minor 3rd/Major 6th", // 2
        "Major 3rd/Minor 6th", // 3
        "Perfect 4th/Perfect 5th", // 4
        "Tritone", // 5
        "Octave" // 6
    ]
    
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
    static let invertedHarmonicIntervalLineColors: [Color] = Array(harmonicIntervalLineColors.prefix(7))
    static let invertedMelodicIntervalLineColors: [Color] = Array(melodicIntervalLineColors.prefix(7))
}
