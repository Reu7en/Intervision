//
//  TestingViewModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation
import SwiftUI
import Combine

class TestingViewModel: ObservableObject {
    var tester: Tester?
    var testSession: TestSession?

    @Published var id = ""
    
    @Published var performerSkillLevel = Tester.SkillLevel.None
    @Published var composerSkillLevel = Tester.SkillLevel.None
    @Published var theoristSkillLevel = Tester.SkillLevel.None
    @Published var educatorSkillLevel = Tester.SkillLevel.None
    @Published var developerSkillLevel = Tester.SkillLevel.None
    
    @Published var questionCount = 90
    
    @Published var tutorial = false {
        didSet {
            if tutorial {
                withAnimation(.easeInOut) {
                    self.presentedView = .Tutorial
                }
            }
        }
    }
    
    @Published var practice = false {
        didSet {
            if practice {
                withAnimation(.easeInOut) {
                    self.presentedView = .Practice
                }
            }
        }
    }
    
    @Published var presentedView: PresentedView = .Registration
    
    @Published var currentQuestion = 0
    @Published var presentedQuestionView: PresentedQuestionView = .CountdownTimer
    
    @Published var countdown = 3
    @Published var progress = 1.0
    private var totalSeconds = 3
    private var timer: AnyCancellable?
    
    var isLastQuestion: Bool {
        self.calculateIsLastQuestion()
    }
}

extension TestingViewModel {
    enum PresentedView {
        case Registration
        case Tutorial
        case Practice
        case Questions
        case Results
    }
    
    enum PresentedQuestionView {
        case CountdownTimer
        case Question
    }
    
    enum Answer: String {
        case Minor2nd = "Minor 2nd"
        case Major2nd = "Major 2nd"
        case Minor3rd = "Minor 3rd"
        case Major3rd = "Major 3rd"
        case Perfect4th = "Perfect 4th"
        case Tritone = "Tritone"
        case Perfect5th = "Perfect 5th"
        case Minor6th = "Minor 6th"
        case Major6th = "Major 6th"
        case Minor7th = "Minor 7th"
        case Major7th = "Major 7th"
        case Octave = "Octave"
        case True = "True"
        case False = "False"
    }
}

extension TestingViewModel {
    func startTests() {
        var testerSkills: [(Tester.Skill, Tester.SkillLevel)] = []
        
        testerSkills.append((Tester.Skill.Performer, performerSkillLevel))
        testerSkills.append((Tester.Skill.Composer, composerSkillLevel))
        testerSkills.append((Tester.Skill.Theorist, theoristSkillLevel))
        testerSkills.append((Tester.Skill.Educator, educatorSkillLevel))
        testerSkills.append((Tester.Skill.Developer, developerSkillLevel))
        
        let testerId: UUID = UUID(uuidString: self.id) ?? UUID()
        
        self.tester = Tester(skills: testerSkills, id: testerId)
        
        if let tester = self.tester {
            self.testSession = TestSession(tester: tester, questionCount: self.questionCount)
        }
        
        withAnimation(.easeInOut) {
            self.presentedView = .Questions
        }
    }
    
    func startCountdown() {
        self.countdown = self.totalSeconds
        self.progress = 1.0
        
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            
            if self.countdown > 0 {
                withAnimation(.easeInOut) {
                    self.countdown -= 1
                    self.progress = CGFloat(self.countdown) / CGFloat(self.totalSeconds)
                }
            } else {
                self.timer?.cancel()
                self.goToQuestion()
            }
        }
    }
    
    func goToQuestion() {
        withAnimation(.easeInOut) {
            self.presentedQuestionView = .Question
        }
    }
    
    func goToNextQuestion() {
        withAnimation(.easeInOut) {
            self.presentedQuestionView = .CountdownTimer
            self.currentQuestion += 1
        }
    }
    
    func goToResults() {
        withAnimation(.easeInOut) {
            self.presentedView = .Results
        }
    }
    
    private func calculateIsLastQuestion() -> Bool {
        return self.currentQuestion + 1 == self.questionCount
    }
    
    func generateQuestionData(question: Question) -> (BarViewModel?, RollViewModel?, [Int]?, Bool?)? {
        let clef: Bar.Clef = Bool.random() ? .Treble : .Bass
        let key: Bar.KeySignature = Bar.KeySignature.allCases.randomElement() ?? .CMajor
        let bar = Bar(chords: [Chord(notes: [])], clef: clef, timeSignature: .custom(beats: 4, noteValue: 4), repeat: nil, doubleLine: false, keySignature: key)
        let lowestGapNote = Note(
            pitch: clef == .Treble ? .F : .A,
            octave: clef == .Treble ? .oneLine : .great,
            duration: .quarter,
            durationValue: -1,
            isRest: false,
            isDotted: false,
            hasAccent: false
        )
        
        let quarterRest = Note(
            duration: .quarter,
            durationValue: -1,
            isRest: true,
            isDotted: false,
            hasAccent: false
        )
        
        let halfRest = Note(
            duration: .half,
            durationValue: -1,
            isRest: true,
            isDotted: false,
            hasAccent: false
        )
        
        switch question.type {
        case .ScoreTwoNoteIntervalIdentification, .RollTwoNoteIntervalIdentification:
            let lowestNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let semitoneIncreases = self.generateDistinctNumbers(count: 2, range: 0...12)
            let answer = semitoneIncreases[1] - semitoneIncreases[0]
            
            for _ in 0..<semitoneIncreases[0] {
                lowestNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<semitoneIncreases[1] {
                highestNote.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote)
            bar.chords[0].notes.append(highestNote)
            bar.chords.append(Chord(notes: [quarterRest]))
            bar.chords.append(Chord(notes: [halfRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                return (barViewModel, nil, [answer], nil)
            } else {
                return nil
            }
        case .ScoreThreeNoteInnerIntervalsIdentification, .RollThreeNoteInnerIntervalsIdentification:
            let lowestNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let middleNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let semitoneIncreases = self.generateDistinctNumbers(count: 3, range: 0...12)
            let answer1 = semitoneIncreases[1] - semitoneIncreases[0]
            let answer2 = semitoneIncreases[2] - semitoneIncreases[1]
            
            for _ in 0..<semitoneIncreases[0] {
                lowestNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<semitoneIncreases[1] {
                middleNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<semitoneIncreases[2] {
                highestNote.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote)
            bar.chords[0].notes.append(middleNote)
            bar.chords[0].notes.append(highestNote)
            bar.chords.append(Chord(notes: [quarterRest]))
            bar.chords.append(Chord(notes: [halfRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                return (barViewModel, nil, [answer1, answer2], nil)
            } else {
                return nil
            }
        case .ScoreThreeNoteOuterIntervalIdentification, .RollThreeNoteOuterIntervalIdentification:
            let lowestNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let middleNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let semitoneIncreases = self.generateDistinctNumbers(count: 3, range: 0...12)
            let answer = semitoneIncreases[2] - semitoneIncreases[0]
            
            for _ in 0..<semitoneIncreases[0] {
                lowestNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<semitoneIncreases[1] {
                middleNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<semitoneIncreases[2] {
                highestNote.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote)
            bar.chords[0].notes.append(middleNote)
            bar.chords[0].notes.append(highestNote)
            bar.chords.append(Chord(notes: [quarterRest]))
            bar.chords.append(Chord(notes: [halfRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                return (barViewModel, nil, [answer], nil)
            } else {
                return nil
            }
        case .ScoreChordsAreInversions, .RollChordsAreInversions:
            let lowestNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let middleNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let semitoneIncreases = self.generateDistinctNumbers(count: 3, range: 0...12)
            
            for _ in 0..<semitoneIncreases[0] {
                lowestNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<semitoneIncreases[1] {
                middleNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<semitoneIncreases[2] {
                highestNote.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote)
            bar.chords[0].notes.append(middleNote)
            bar.chords[0].notes.append(highestNote)
            bar.chords.append(Chord(notes: [quarterRest]))
            bar.chords.append(Chord(notes: []))
            
            if Bool.random() { // Apply 1st or 2nd inversion
                for _ in 0..<12 {
                    lowestNote.increaseSemitone(sharps: key.sharps)
                }
            } else {
                for _ in 0..<12 {
                    lowestNote.increaseSemitone(sharps: key.sharps)
                    middleNote.increaseSemitone(sharps: key.sharps)
                }
            }
            
            let answer = Bool.random()
            
            if !answer {
                let semitonesToAdjust = Int.random(in: 1...2) * (Bool.random() ? 1 : -1)
                
                if Bool.random() { // Adjust lowest note
                    if semitonesToAdjust > 0 {
                        for _ in 0..<semitonesToAdjust {
                            lowestNote.increaseSemitone(sharps: key.sharps)
                        }
                    } else {
                        for _ in 0..<abs(semitonesToAdjust) {
                            lowestNote.decreaseSemitone(sharps: key.sharps)
                        }
                    }
                } else { // Adjust middle note
                    if semitonesToAdjust > 0 {
                        for _ in 0..<semitonesToAdjust {
                            middleNote.increaseSemitone(sharps: key.sharps)
                        }
                    } else {
                        for _ in 0..<abs(semitonesToAdjust) {
                            middleNote.decreaseSemitone(sharps: key.sharps)
                        }
                    }
                }
            }
            
            bar.chords[2].notes.append(lowestNote)
            bar.chords[2].notes.append(middleNote)
            bar.chords[2].notes.append(highestNote)
            bar.chords.append(Chord(notes: [quarterRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                return (barViewModel, nil, nil, answer)
            } else {
                return nil
            }
        case .ScoreTwoNoteIntervalsAreEqual, .RollTwoNoteIntervalsAreEqual:
            let lowestNote1 = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote1 = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let lowestNote2 = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote2 = Note(
                pitch: lowestGapNote.pitch,
                octave: lowestGapNote.octave,
                duration: .quarter,
                durationValue: -1,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let semitoneIncreases = self.generateDistinctNumbers(count: 2, range: 0...12)
            
            for _ in 0..<semitoneIncreases[0] {
                lowestNote1.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<semitoneIncreases[1] {
                highestNote1.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote1)
            bar.chords[0].notes.append(highestNote1)
            bar.chords.append(Chord(notes: [quarterRest]))
            bar.chords.append(Chord(notes: []))
            
            let answer = Bool.random()
            let lowestNote2SemitoneIncrease = Int.random(in: 1...11)
            let highestNote2SemitoneIncrease = answer ? lowestNote2SemitoneIncrease + semitoneIncreases[1] : lowestNote2SemitoneIncrease + semitoneIncreases[1] + (Int.random(in: 1...2) * (Bool.random() ? 1 : -1))
            
            for _ in 0..<(semitoneIncreases[0] + lowestNote2SemitoneIncrease) {
                lowestNote2.increaseSemitone(sharps: key.sharps)
            }
            
            if highestNote2SemitoneIncrease > 0 {
                for _ in 0..<highestNote2SemitoneIncrease {
                    highestNote2.increaseSemitone(sharps: key.sharps)
                }
            } else {
                for _ in 0..<abs(highestNote2SemitoneIncrease) {
                    highestNote2.decreaseSemitone(sharps: key.sharps)
                }
            }
            
            bar.chords[2].notes.append(lowestNote2)
            bar.chords[2].notes.append(highestNote2)
            bar.chords.append(Chord(notes: [quarterRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                return (barViewModel, nil, nil, answer)
            } else {
                return nil
            }
        }
    }
    
    private func generateDistinctNumbers(count: Int, range: ClosedRange<Int>) -> [Int] {
        var numbers = Set<Int>()
        
        while numbers.count < count {
            numbers.insert(Int.random(in: range))
        }
        
        return numbers.sorted()
    }
}
