//
//  RollViewModel.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import Foundation
import SwiftUI
import Combine

class RollViewModel: ObservableObject {
    
    @ObservedObject var scoreManager: ScoreManager
    
    @Published var parts: [Part]? {
        didSet {
            calculateSegments()
        }
    }
    
    @Published var segments: [[[[Segment]]]]? // part->bar->stave->segment
    
    @Published var partGroups: [(String, [Part])]
    
    @Published var octaves: Int
    @Published var harmonicIntervalLinesType: IntervalLinesViewModel.IntervalLinesType
    @Published var showMelodicIntervalLines: Bool
    @Published var viewablePartSegmentColors: [Color]
    @Published var viewableHarmonicIntervalLineColors: [Color]
    @Published var viewableMelodicIntervalLineColors: [Color]
    @Published var viewableIntervals: [String]
    @Published var viewableMelodicLines: [Part]
    @Published var showInvertedIntervals: Bool
    @Published var showZigZags: Bool
    
    @Published var selectedSegments: [(Segment, Bar)]
    
    @Published var isSegmentHeld: Bool
    
    private var keyboardEventMonitor: Any?
    private var mouseEventMonitor: Any?
    private var rowHeight: CGFloat?
    private var barWidth: CGFloat?
    private var lastMouseLocation: CGPoint?
    
    init(
        scoreManager: ScoreManager,
        parts: [Part]? = nil,
        segments: [[[[Segment]]]]? = nil,
        partGroups: [(String, [Part])] = [],
        octaves: Int = 9,
        harmonicIntervalLinesType: IntervalLinesViewModel.IntervalLinesType = .none,
        showMelodicIntervalLines: Bool = false,
        viewablePartSegmentColors: [Color] = partSegmentColors,
        viewableHarmonicIntervalLineColors: [Color] = harmonicIntervalLineColors,
        viewableMelodicIntervalLineColors: [Color] = melodicIntervalLineColors,
        viewableIntervals: [String] = intervals,
        viewableMelodicLines: [Part] = [],
        showInvertedIntervals: Bool = false,
        showZigZags: Bool = false,
        selectedSegments: [(Segment, Bar)] = [],
        isSegmentHeld: Bool = false
    ) {
        self.scoreManager = scoreManager
        self.parts = parts
        self.segments = segments
        self.partGroups = partGroups
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
        self.selectedSegments = selectedSegments
        self.isSegmentHeld = isSegmentHeld
    }
    
    func updateRowHeight(_ height: CGFloat) {
        self.rowHeight = height
    }
    
    func updateBarWidth(_ width: CGFloat) {
        self.barWidth = width
    }
    
    func setupEventMonitoring() {
        keyboardEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
        
        mouseEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged, .leftMouseUp]) { [weak self] event in
            self?.handleMouseEvent(event)
            return event
        }
    }
    
    func stopEventMonitoring() {
        if let keyboardEventMonitor = keyboardEventMonitor {
            NSEvent.removeMonitor(keyboardEventMonitor)
        }
        
        if let mouseEventMonitor = mouseEventMonitor {
            NSEvent.removeMonitor(mouseEventMonitor)
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        switch event.keyCode {
            case 53: // esc
                clearSelectedSegments()
            case 126: // up
                handleKeyUp()
            case 125: // down
                handleKeyDown()
            case 123: // left
                handleKeyLeft()
            case 124: // right
                handleKeyRight()
            default:
                break
        }
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        guard let rowHeight = rowHeight,
              let barWidth = barWidth else { return }
        
        switch event.type {
        case .leftMouseDragged:
            guard let lastLocation = lastMouseLocation else {
                lastMouseLocation = event.locationInWindow
                return
            }
            
            let currentLocation = event.locationInWindow
            let deltaX = currentLocation.x - lastLocation.x
            let deltaY = currentLocation.y - lastLocation.y
            
            if abs(deltaX) >= barWidth * 0.0625 && isSegmentHeld {
                lastMouseLocation = currentLocation
                let i = abs(Int(deltaX / (barWidth * 0.0625)))
                
                for _ in 0..<i {
                    if deltaX > 0 {
                        handleKeyRight()
                    } else {
                        handleKeyLeft()
                    }
                }
            }
            
            if abs(deltaY) >= rowHeight && isSegmentHeld {
                lastMouseLocation = currentLocation
                let i = abs(Int(deltaY / rowHeight))
                
                for _ in 0..<i {
                    if deltaY > 0 {
                        handleKeyUp()
                    } else {
                        handleKeyDown()
                    }
                }
            }
        case .leftMouseUp:
            isSegmentHeld = false
        default:
            lastMouseLocation = nil
        }
    }
    
    func refresh() {
        objectWillChange.send()
    }
    
    func handleKeyUp() {
        for segment in selectedSegments {
            segment.0.increaseSemitone()
        }
        
        refresh()
    }
    
    func handleKeyDown() {
        for segment in selectedSegments {
            segment.0.decreaseSemitone()
        }
        
        refresh()
    }
    
    func handleKeyLeft() {
        var minDuration = 0.0625
        
        for segment in selectedSegments {
            minDuration = min(minDuration, segment.0.duration)
        }
        
        for segment in selectedSegments {
            segment.0.moveLeft(moveAmount: minDuration)
        }
        
        refresh()
    }
    
    func handleKeyRight() {
        var minDuration = 0.0625
        
        for segment in selectedSegments {
            minDuration = min(minDuration, segment.0.duration)
        }
        
        for segment in selectedSegments {
            var barDuration: Double = -1
            
            switch segment.1.timeSignature {
            case .common:
                barDuration = 1
            case .cut:
                barDuration = 1
            case .custom(let beats, let noteValue):
                barDuration = Double(beats) / Double(noteValue)
            }
            
            if barDuration != -1 {
                segment.0.moveRight(moveAmount: minDuration, barDuration: barDuration)
            }
        }
        
        refresh()
    }
    
    func removeCoveredSegments(_ sortedSegments: inout [Segment]) {
        var segmentsToRemove: [Segment] = []

        for i in 0..<sortedSegments.count {
            let currentSegment = sortedSegments[i]
            
            for j in (i+1)..<sortedSegments.count {
                let otherSegment = sortedSegments[j]
                
                if currentSegment.rowIndex == otherSegment.rowIndex {
                    if currentSegment.durationPreceeding <= otherSegment.durationPreceeding &&
                       (currentSegment.durationPreceeding + currentSegment.duration) >= (otherSegment.durationPreceeding + otherSegment.duration) {
                        segmentsToRemove.append(otherSegment)
                    } else if otherSegment.durationPreceeding <= currentSegment.durationPreceeding &&
                              (otherSegment.durationPreceeding + otherSegment.duration) >= (currentSegment.durationPreceeding + currentSegment.duration) {
                        segmentsToRemove.append(currentSegment)
                    }
                }
            }
        }

        sortedSegments = sortedSegments.filter { !segmentsToRemove.contains($0) }
    }
    
    func updateBar(barToUpdate: Bar) {
        guard let currentParts = self.parts else { return }
        
        for partIndex in 0..<currentParts.count {
            for barIndex in 0..<currentParts[partIndex].bars.count {
                for (staveIndex, bar) in currentParts[partIndex].bars[barIndex].enumerated() {
                    if bar == barToUpdate {
                        if let segments = self.segments {
                            var sortedSegments = segments[partIndex][barIndex][staveIndex].sorted { $0.durationPreceeding < $1.durationPreceeding }
                            removeCoveredSegments(&sortedSegments)
                            self.segments?[partIndex][barIndex][staveIndex] = sortedSegments
                            
                            let newBar = Bar(chords: [], tempo: barToUpdate.tempo, clef: barToUpdate.clef, timeSignature: barToUpdate.timeSignature, repeat: barToUpdate.repeat, doubleLine: barToUpdate.doubleLine, volta: barToUpdate.volta, keySignature: barToUpdate.keySignature, dynamics: barToUpdate.dynamics, id: barToUpdate.id)
                            
                            var barDuration: Double = -1
                            
                            switch barToUpdate.timeSignature {
                            case .common:
                                barDuration = 1
                            case .cut:
                                barDuration = 1
                            case .custom(let beats, let noteValue):
                                barDuration = Double(beats) / Double(noteValue)
                            }
                            
                            var groups: [[Segment]] = []
                            var currentGroup: [Segment] = []
                            var currentLongestDurationPoint: Double = 0
                            
                            for segment in sortedSegments {
                                if segment.durationPreceeding + segment.duration > barDuration {
                                    segment.duration = barDuration - segment.durationPreceeding
                                }
                                
                                if segment.durationPreceeding != 0 && groups.isEmpty && currentGroup.isEmpty {
                                    groups.append([Segment(rowIndex: -1, duration: segment.durationPreceeding, durationPreceeding: 0, dynamic: nil, note: nil, sharps: barToUpdate.keySignature.sharps)])
                                }
                                
                                if segment.durationPreceeding < currentLongestDurationPoint {
                                    currentGroup.append(segment)
                                } else {
                                    if !currentGroup.isEmpty {
                                        groups.append(currentGroup)
                                        
                                        if let lastSegment = currentGroup.last {
                                            let delta = segment.durationPreceeding - (lastSegment.duration + lastSegment.durationPreceeding)
                                            
                                            if delta > 0 {
                                                groups.append([Segment(rowIndex: -1, duration: delta, durationPreceeding: lastSegment.duration + lastSegment.durationPreceeding, dynamic: nil, note: nil, sharps: barToUpdate.keySignature.sharps)]) // rest segment
                                            }
                                        }
                                    }
                                    
                                    currentGroup = [segment]
                                }
                                
                                currentLongestDurationPoint = max(currentLongestDurationPoint, segment.duration + segment.durationPreceeding)
                            }
                            
                            if !currentGroup.isEmpty {
                                groups.append(currentGroup)
                            }
                            
                            if barDuration != -1 {
                                if let lastSegment = currentGroup.last {
                                    let delta = barDuration - (lastSegment.duration + lastSegment.durationPreceeding)
                                    
                                    if delta > 0 {
                                        groups.append([Segment(rowIndex: -1, duration: delta, durationPreceeding: lastSegment.duration + lastSegment.durationPreceeding, dynamic: nil, note: nil, sharps: barToUpdate.keySignature.sharps)]) // rest segment
                                    }
                                }
                            }
                            
                            var chordGroups: [[(Segment, Note.Tie?)]] = []
                            
                            for group in groups {
                                let sortedGroup = group.sorted { $0.durationPreceeding < $1.durationPreceeding }
                                var times: [Double] = []
                                
                                if let firstSegment = sortedGroup.first, firstSegment.rowIndex == -1 {
                                    chordGroups.append([(firstSegment, nil)])
                                    continue
                                }
                                
                                for segment in sortedGroup {
                                    if !times.contains(segment.durationPreceeding) {
                                        times.append(segment.durationPreceeding)
                                    }
                                    
                                    if !times.contains(segment.durationPreceeding + segment.duration) {
                                        times.append(segment.durationPreceeding + segment.duration)
                                    }
                                }
                                
                                let sortedTimes = times.sorted()
                                var currentChords: [[(Segment, Note.Tie?)]] = Array(repeating: [], count: sortedTimes.count)
                                
                                for segment in sortedSegments {
                                    var startChordIndex: Int?
                                    var endChordIndex: Int?
                                    var tie: Note.Tie?
                                    
                                    for (index, time) in sortedTimes.enumerated() {
                                        if time == segment.durationPreceeding {
                                            startChordIndex = index
                                        }
                                        
                                        if time == segment.durationPreceeding + segment.duration {
                                            endChordIndex = index
                                        }
                                    }
                                    
                                    if let start = startChordIndex,
                                       let end = endChordIndex, start < end {
                                        if end - start == 1 {
                                            currentChords[start].append((segment, tie))
                                        } else {
                                            for i in start..<end {
                                                if i == start {
                                                    tie = .Start
                                                } else if i == end - 1 {
                                                    tie = .Stop
                                                } else {
                                                    tie = .Both
                                                }
                                                
                                                currentChords[i].append((Segment(rowIndex: segment.rowIndex, duration: times[i + 1] - times[i], durationPreceeding: times[i], dynamic: segment.dynamic, note: segment.note, sharps: barToUpdate.keySignature.sharps), tie))
                                            }
                                        }
                                    }
                                }
                                
                                for chord in currentChords {
                                    if !chord.isEmpty {
                                        chordGroups.append(chord)
                                    }
                                }
                            }
                            
                            if chordGroups.isEmpty {
                                newBar.chords = [Chord(notes: [Note(duration: .bar, isRest: true, isDotted: false, hasAccent: false)])]
                            } else {
                                for chord in chordGroups {
                                    var newChords: [Chord] = []
                                    
                                    for segment in chord {
                                        if segment.0.rowIndex == -1 {
                                            if let duration = Note.Duration(rawValue: segment.0.duration) {
                                                newBar.chords.append(Chord(notes: [Note(duration: duration, isRest: true, isDotted: false, hasAccent: false)]))
                                            } else if let duration = Note.Duration(rawValue: segment.0.duration / 1.5) {
                                                newBar.chords.append(Chord(notes: [Note(duration: duration, isRest: true, isDotted: true, hasAccent: false)]))
                                            } else {
                                                var timeLeft = segment.0.duration
                                                var durations: [Note.Duration] = []
                                                
                                                while timeLeft > 0 {
                                                    var minDelta = Double.infinity
                                                    var durationToAdd = Double.infinity
                                                    
                                                    for durationValue in Note.Duration.allCases {
                                                        let raw = durationValue.rawValue
                                                        let delta = timeLeft - raw

                                                        if delta >= 0 && delta < minDelta {
                                                            minDelta = delta
                                                            durationToAdd = raw
                                                        }
                                                    }
                                                    
                                                    if minDelta == .infinity {
                                                        newBar.chords = [Chord(notes: [Note(duration: .bar, isRest: true, isDotted: false, hasAccent: false)])]
                                                        break
                                                    }
                                                    
                                                    if let duration = Note.Duration(rawValue: durationToAdd), durationToAdd != 0 {
                                                        durations.append(duration)
                                                        timeLeft -= durationToAdd
                                                    } else {
                                                        break
                                                    }
                                                }
                                                
                                                for duration in durations {
                                                    newBar.chords.append(Chord(notes: [Note(duration: duration, isRest: true, isDotted: false, hasAccent: false)]))
                                                }
                                            }
                                        } else {
                                            if let (pitch, accidental, octave) = calculatePitchAccidentalOctave(rowIndex: segment.0.rowIndex, sharps: newBar.keySignature.sharps) {
                                                if let duration = Note.Duration(rawValue: segment.0.duration) {
                                                    if newChords.isEmpty {
                                                        newChords = [Chord(notes: [])]
                                                    }
                                                    
                                                    newChords[0].notes.append((Note(pitch: pitch, accidental: accidental, octave: octave, octaveShift: nil, duration: duration, timeModification: segment.0.note?.timeModification, changeDynamic: segment.0.note?.changeDynamic, graceNotes: nil, tie: segment.1, slur: nil, isRest: false, isDotted: false, hasAccent: segment.0.note?.hasAccent ?? false, id: UUID())))
                                                } else if let duration = Note.Duration(rawValue: segment.0.duration / 1.5) {
                                                    if newChords.isEmpty {
                                                        newChords = [Chord(notes: [])]
                                                    }
                                                    
                                                    newChords[0].notes.append((Note(pitch: pitch, accidental: accidental, octave: octave, octaveShift: nil, duration: duration, timeModification: segment.0.note?.timeModification, changeDynamic: segment.0.note?.changeDynamic, graceNotes: nil, tie: segment.1, slur: nil, isRest: false, isDotted: true, hasAccent: segment.0.note?.hasAccent ?? false, id: UUID())))
                                                } else {
                                                    var timeLeft = segment.0.duration
                                                    var durations: [(Note.Duration, Bool)] = []
                                                    
                                                    while timeLeft > 0 {
                                                        var minDelta = Double.infinity
                                                        var durationToAdd = Double.infinity
                                                        
                                                        for durationValue in Note.Duration.allCases {
                                                            let raw = durationValue.rawValue
                                                            let delta = timeLeft - raw
                                                            let rawDotted = durationValue.rawValue * 1.5
                                                            let deltaDotted = timeLeft - rawDotted

                                                            if deltaDotted >= 0 && deltaDotted < minDelta {
                                                                minDelta = deltaDotted
                                                                durationToAdd = rawDotted
                                                            } else if delta >= 0 && delta < minDelta {
                                                                minDelta = delta
                                                                durationToAdd = raw
                                                            }
                                                        }
                                                        
                                                        if minDelta == .infinity {
                                                            newBar.chords = [Chord(notes: [Note(duration: .bar, isRest: true, isDotted: false, hasAccent: false)])]
                                                            break
                                                        }
                                                        
                                                        if let duration = Note.Duration(rawValue: durationToAdd), durationToAdd != 0 {
                                                            durations.append((duration, false))
                                                            timeLeft -= durationToAdd
                                                        } else if let duration = Note.Duration(rawValue: durationToAdd / 1.5), durationToAdd != 0 {
                                                            durations.append((duration, true))
                                                            timeLeft -= durationToAdd
                                                        } else {
                                                            break
                                                        }
                                                    }
                                                    
                                                    if newChords.isEmpty {
                                                        newChords = Array(repeating: Chord(notes: []), count: durations.count)
                                                    }
                                                    
                                                    for (durationIndex, duration) in durations.enumerated() {
                                                        let tie = durationIndex == 0 ? Note.Tie.Start : durationIndex == durations.count - 1 ? Note.Tie.Stop : Note.Tie.Both
                                                        
                                                        newChords[durationIndex].notes.append(Note(pitch: pitch, accidental: accidental, octave: octave, octaveShift: nil, duration: duration.0, timeModification: segment.0.note?.timeModification, changeDynamic: segment.0.note?.changeDynamic, graceNotes: nil, tie: tie, slur: nil, isRest: false, isDotted: duration.1, hasAccent: segment.0.note?.hasAccent ?? false, id: UUID()))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    for chord in newChords {
                                        newBar.chords.append(chord)
                                    }
                                }
                            }
                            
                            self.parts?[partIndex].bars[barIndex][staveIndex] = newBar
                        }
                    }
                }
            }
        }
    }
    
    func calculatePitchAccidentalOctave(rowIndex: Int, sharps: Bool) -> (Note.Pitch, Note.Accidental?, Note.Octave)? {
        let octave: Note.Octave? = Note.Octave(rawValue: self.octaves - ((1 + rowIndex) / 12) - 1)
        let pitchValue = rowIndex % 12
        var pitch: Note.Pitch?
        var accidental: Note.Accidental?
        
        switch pitchValue {
        case 11:
            pitch = .C
        case 10:
            if sharps {
                pitch = .C
                accidental = .Sharp
            } else {
                pitch = .D
                accidental = .Flat
            }
        case 9:
            pitch = .D
        case 8:
            if sharps {
                pitch = .D
                accidental = .Sharp
            } else {
                pitch = .E
                accidental = .Flat
            }
        case 7:
            pitch = .E
        case 6:
            pitch = .F
        case 5:
            if sharps {
                pitch = .F
                accidental = .Sharp
            } else {
                pitch = .G
                accidental = .Flat
            }
        case 4:
            pitch = .G
        case 3:
            if sharps {
                pitch = .G
                accidental = .Sharp
            } else {
                pitch = .A
                accidental = .Flat
            }
        case 2:
            pitch = .A
        case 1:
            if sharps {
                pitch = .A
                accidental = .Sharp
            } else {
                pitch = .B
                accidental = .Flat
            }
        case 0:
            pitch = .B
        default:
            break
        }
        
        if let pitch = pitch,
           let octave = octave {
            return (pitch, accidental, octave)
        }
        
        return nil
    }

    func updateScoreParts() {
        guard let score = scoreManager.score, let updatedParts = parts else { return }
        
        if var existingParts = score.parts {
            for part in updatedParts {
                if let index = existingParts.firstIndex(where: { $0.id == part.id }) {
                    existingParts[index] = part
                } else {
                    existingParts.append(part)
                }
            }
            
            score.parts = existingParts
        } else {
            score.parts = updatedParts
        }
        
        refresh()
    }

    
    func handleSegmentClicked(segment: Segment, bar: Bar?, isCommandKeyDown: Bool) {
        guard let currentBar = bar else { return }
        
        if isCommandKeyDown {
            if selectedSegments.contains(where: { $0 == (segment, currentBar) }) {
                segment.isSelected = false
                selectedSegments.removeAll(where: { $0 == (segment, currentBar) })
            } else {
                segment.isSelected = true
                selectedSegments.append((segment, currentBar))
            }
        } else {
            if selectedSegments.contains(where: { $0 == (segment, currentBar) }) {
                segment.isSelected = false
                selectedSegments.removeAll(where: { $0 == (segment, currentBar) })
            } else {
                segment.isSelected = true
                
                for selectedSegment in selectedSegments {
                    selectedSegment.0.isSelected = false
                }
                
                selectedSegments = [(segment, currentBar)]
            }
        }
    }
    
    func clearSelectedSegments() {
//        for segment in selectedSegments {
//            updateBar(barToUpdate: segment.1)
//        }
        
        updateScoreParts()
        
        for segment in selectedSegments {
            segment.0.isSelected = false
        }
        
        self.selectedSegments = []
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
        
        if parts.count > viewablePartSegmentColors.count {
            for _ in 0..<(parts.count - viewablePartSegmentColors.count) {
                viewablePartSegmentColors.append(Color.clear)
            }
        }
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
    
    func addViewableMelodicLine(_ part: Part) {
        if !viewableMelodicLines.contains(part) {
            viewableMelodicLines.append(part)
        }
    }
    
    func removeViewableMelodicLine(_ part: Part) {
        viewableMelodicLines.removeAll(where: { $0 == part })
    }
    
    func addAllViewableMelodicLines() {
        if let score = scoreManager.score,
           let scoreParts = score.parts {
            for part in scoreParts {
                addViewableMelodicLine(part)
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
                                case .custom(let actual, let normal, _): // investigate normalDuration
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
                                            case .custom(let actual, let normal, _): // investigate normalDuration
                                                duration /= (Double(actual) / Double(normal))
                                            }
                                        }
                                        
                                        barSegments.append(
                                            Segment(
                                                rowIndex: rowIndex,
                                                duration: duration,
                                                durationPreceeding: durationPreceeding,
                                                dynamic: currentDynamics[staveIndex],
                                                note: note, 
                                                sharps: bar.keySignature.sharps
                                            )
                                        )
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
