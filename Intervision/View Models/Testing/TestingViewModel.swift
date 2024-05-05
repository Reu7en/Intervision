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

    @Published var testerId = ""
    
    @Published var performerSkillLevel = Skill.SkillLevel.None
    @Published var composerSkillLevel = Skill.SkillLevel.None
    @Published var theoristSkillLevel = Skill.SkillLevel.None
    @Published var educatorSkillLevel = Skill.SkillLevel.None
    @Published var developerSkillLevel = Skill.SkillLevel.None
    
    @Published var rollRowsViewType = BarRowsView.ViewType.Piano
    @Published var showPiano = false
    
    @Published var tutorial = false {
        didSet {
            if tutorial {
                withAnimation(.easeInOut) {
                    self.presentedView = .Tutorial
                }
            }
        }
    }
    
    @Published var practice = false
    @Published var random = false
    @Published var presentedView: PresentedView = .Registration
    @Published var presentedQuestionView: PresentedQuestionView = .CountdownTimer
    @Published var showSavingErrorAlert = false
    @Published var showSavingSuccessAlert = false
    @Published var showSavingEmailAlert = false
    @Published var participantInformationSheetSaved = true // CHANGE
    @Published var consentFormSaved = true // CHANGE
    @Published var resultsURL: IdentifiableURL?
    @Published var pdfURL: IdentifiableURL?
    
    @Published var countdown = 1
    @Published var progress = 1.0
    private let totalSeconds = 1
    private var countdownTimer: AnyCancellable?
    
    var isFirstQuestion = true
    
    var isLastQuestion: Bool {
        self.calculateIsLastQuestion()
    }
    
    @Published var currentQuestionIndex = 0 {
        didSet {
            if currentQuestionIndex == 0 {
                self.isFirstQuestion = true
            }
            
            if self.practice || self.random {
                self.randomlyGenerateQuestionData(question: self.testSession?.questions[currentQuestionIndex])
                self.testSession?.random = self.random
            } else {
                self.setTestQuestionData(currentQuestionIndex)
            }
            
            self.questionResults = []
            self.questionMarked = false
        }
    }
    
    @Published var testQuestionData: [(BarViewModel?, (RollViewModel, IntervalLinesViewModel)?, [Answer]?)?] = []
    @Published var currentQuestionData: (BarViewModel?, (RollViewModel, IntervalLinesViewModel)?, [Answer]?)?
    @Published var questionResults: [Bool] = []
    @Published var questionMarked = false
    @Published var questionVisible = false
    
    @Published var answerTime = 0.0
    @Published var answerProgress = 1.0
    let maximumAnswerTime = 60.0
    private var answerTimer: AnyCancellable?
}

struct IdentifiableURL: Identifiable {
    let id: UUID = UUID()
    let url: URL
}

extension TestingViewModel {
    enum PresentedView {
        case Registration
        case Tutorial
        case Questions
        case Results
    }
    
    enum PresentedQuestionView {
        case CountdownTimer
        case Question
    }
    
    enum Answer: String, CaseIterable {
        case Minor2nd = "Minor 2nd"
        case Major2nd = "Major 2nd"
        case Minor3rd = "Minor 3rd"
        case Major3rd = "Major 3rd"
        case Perfect4th = "Perf. 4th"
        case Tritone = "Tritone"
        case Perfect5th = "Perf. 5th"
        case Minor6th = "Minor 6th"
        case Major6th = "Major 6th"
        case Minor7th = "Minor 7th"
        case Major7th = "Major 7th"
        case Octave = "Octave"
        
        case True = "True"
        case False = "False"
        
        var isBoolQuestion: Bool {
            switch self {
            case .True, .False:
                    return true
            default:
                    return false
            }
        }
        
        init?(semitones: Int? = nil, boolValue: Bool? = nil) {
            if let boolValue = boolValue {
                self = boolValue ? .True : .False
                
                return
            }

            if let semitones = semitones {
                switch semitones.trueModulo(12) {
                    case 1:
                        self = .Minor2nd
                    case 2:
                        self = .Major2nd
                    case 3:
                        self = .Minor3rd
                    case 4:
                        self = .Major3rd
                    case 5:
                        self = .Perfect4th
                    case 6:
                        self = .Tritone
                    case 7:
                        self = .Perfect5th
                    case 8:
                        self = .Minor6th
                    case 9:
                        self = .Major6th
                    case 10:
                        self = .Minor7th
                    case 11:
                        self = .Major7th
                    case 12, 0:
                        self = .Octave
                    default:
                        return nil
                }
                
                return
            }

            return nil
        }
    }
}

extension TestingViewModel {
    func startTests() {
        var testerSkills: [Skill] = []
        
        testerSkills.append(Skill(type: .Performer, level: self.performerSkillLevel))
        testerSkills.append(Skill(type: .Composer, level: self.composerSkillLevel))
        testerSkills.append(Skill(type: .Theorist, level: self.theoristSkillLevel))
        testerSkills.append(Skill(type: .Educator, level: self.educatorSkillLevel))
        testerSkills.append(Skill(type: .Developer, level: self.developerSkillLevel))
        
        let testerId: UUID = UUID(uuidString: self.testerId) ?? UUID()
        
        self.tester = Tester(skills: testerSkills, id: testerId)
        
        if let tester = self.tester {
            self.testSession = TestSession(tester: tester, questionCount: 30)
        }

        self.generateTestQuestionData()
        self.currentQuestionIndex = 0
        self.goToNextQuestion()
    }
    
    func startCountdown() {
        self.countdown = self.totalSeconds
        self.progress = 1.0
        
        if self.isFirstQuestion {
            self.isFirstQuestion = false
        } else {
            self.currentQuestionIndex += 1
        }
        
        self.countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            
            if self.countdown > 0 {
                withAnimation(.easeInOut) {
                    self.countdown -= 1
                    self.progress = CGFloat(self.countdown) / CGFloat(self.totalSeconds)
                }
            } else {
                self.countdownTimer?.cancel()
                self.countdownTimer = nil
                self.goToQuestion()
            }
        }
    }
    
    func startAnswerTimer() {
        self.answerTime = 0.0
        self.answerProgress = 1.0
        
        self.answerTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            
            if self.answerTime < self.maximumAnswerTime {
                self.answerTime += 0.01
                self.answerProgress = CGFloat(self.answerTime) / CGFloat(self.maximumAnswerTime)
            } else {
                self.stopAnswerTimer()
                
                if !self.questionMarked {
                    self.markQuestion()
                }
            }
        }
    }
    
    func stopAnswerTimer() {
        self.answerTimer?.cancel()
        self.answerTimer = nil
    }
    
    func goToQuestion() {
        withAnimation(.easeInOut) {
            self.presentedView = .Questions
            self.presentedQuestionView = .Question
            self.questionVisible = true
            self.startAnswerTimer()
        }
    }
    
    func goToNextQuestion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.presentedView = .Questions
                self.presentedQuestionView = .CountdownTimer
            }
        }
    }
    
    func goToResults() {
        withAnimation(.easeInOut) {
            self.presentedView = .Results
        }
    }
    
    func submitAnswer(questionData: (BarViewModel?, (RollViewModel, IntervalLinesViewModel)?, [Answer]?), answer: Answer, answerIndex: Int) {
        guard let answers = questionData.2 else { self.questionMarked = true; return }
        
        self.questionResults.append(answer.rawValue == answers[answerIndex].rawValue)
        
        if self.questionResults.count == answers.count {
            self.markQuestion()
        }
    }
    
    func markQuestion() {
        self.stopAnswerTimer()
        
        withAnimation(.easeInOut) {
            self.questionMarked = true
        }
        
        if let question = self.testSession?.questions[self.currentQuestionIndex] {
            let answeredCorrectly = self.questionResults.isEmpty ? false : self.questionResults.allSatisfy( { $0 == true } )
            let timeTaken = self.questionResults.isEmpty ? -1 : self.answerTime
            
            self.testSession?.results.append(TestResult(question: question, answeredCorrectly: answeredCorrectly, timeTaken: timeTaken))
        }
    }
    
    func saveTestSession() {
        guard let testSession = self.testSession else { self.showSavingErrorAlert = true; return }

        #if os(macOS)
        let panel = NSSavePanel()
        
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "\(testSession.id).json"

        panel.begin { response in
            if response == .OK, let temporaryURL = panel.url {
                do {
                    let encoder = JSONEncoder()
                    
                    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    
                    let jsonData = try encoder.encode(testSession)
                    try jsonData.write(to: temporaryURL)
                    
                    DispatchQueue.main.async {
                        self.showSavingSuccessAlert = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showSavingErrorAlert = true
                    }
                }
            }
        }
        #elseif os(iOS)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(testSession)
            let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(testSession.id).json")
            try jsonData.write(to: temporaryURL)
            
            DispatchQueue.main.async {
                self.resultsURL = IdentifiableURL(url: temporaryURL)
            }
        } catch {
            DispatchQueue.main.async {
                self.showSavingErrorAlert = true
            }
        }
        #endif
    }
    
    func savePDF(named filename: String) {
        guard let pdfURL = Bundle.main.url(forResource: filename, withExtension: "pdf") else { self.showSavingErrorAlert = true; return }
        
        #if os(macOS)
        let panel = NSSavePanel()
        
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "\(filename).pdf"

        panel.begin { response in
            if response == .OK, let temporaryURL = panel.url {
                do {
                    let pdfData = try Data(contentsOf: pdfURL)
                    try pdfData.write(to: temporaryURL)
                } catch {
                    DispatchQueue.main.async {
                        self.showSavingErrorAlert = true
                    }
                }
            }
        }
        #elseif os(iOS)
        do {
            let pdfData = try Data(contentsOf: pdfURL)
            let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")
            try pdfData.write(to: temporaryURL)
            
            DispatchQueue.main.async {
                self.pdfURL = IdentifiableURL(url: temporaryURL)
            }
        } catch {
            DispatchQueue.main.async {
                self.showSavingErrorAlert = true
            }
        }
        #endif
    }
    
    func getTotalQuestionsCorrect() -> Int? {
        guard let testSession = self.testSession, !testSession.results.isEmpty else { return nil }
        
        return testSession.results.filter( { $0.answeredCorrectly } ).count
    }
    
    func getScoreQuestionsCorrect() -> Int? {
        guard let testSession = self.testSession, !testSession.results.isEmpty else { return nil }
        
        return testSession.results.filter( { $0.answeredCorrectly && $0.question.type.isScoreQuestion } ).count
    }
    
    func getRollQuestionsCorrect() -> Int? {
        guard let testSession = self.testSession, !testSession.results.isEmpty else { return nil }
        
        return testSession.results.filter( { $0.answeredCorrectly && !$0.question.type.isScoreQuestion } ).count
    }
     
    func getTotalPercentageAccuracy() -> Double? {
        guard let testSession = self.testSession, !testSession.results.isEmpty else { return nil }
        
        return 100 * Double(testSession.results.filter( { $0.answeredCorrectly } ).count) / Double(testSession.results.count)
    }
    
    func getScorePercentageAccuracy() -> Double? {
        guard let testSession = self.testSession, !testSession.results.filter( { $0.question.type.isScoreQuestion } ).isEmpty else { return nil }
        
        return 100 * Double(testSession.results.filter( { $0.answeredCorrectly && $0.question.type.isScoreQuestion } ).count) / Double(testSession.results.count)
    }
    
    func getRollPercentageAccuracy() -> Double? {
        guard let testSession = self.testSession, !testSession.results.filter( { !$0.question.type.isScoreQuestion } ).isEmpty else { return nil }
        
        return 100 * Double(testSession.results.filter( { $0.answeredCorrectly && !$0.question.type.isScoreQuestion } ).count) / Double(testSession.results.count)
    }
    
    func getAverageAnswerTime() -> Double? {
        guard let testSession = self.testSession, !testSession.results.isEmpty else { return nil }
        
        let result = testSession.results.filter( { $0.answeredCorrectly } ).compactMap( { $0.timeTaken } ).reduce(0, +) / Double(testSession.results.count)
        
        return result > 0 ? result : nil
    }
    
    func getAverageScoreAnswerTime() -> Double? {
        guard let testSession = self.testSession, !testSession.results.isEmpty else { return nil }
        
        let result = testSession.results.filter( { $0.answeredCorrectly && $0.question.type.isScoreQuestion } ).compactMap( { $0.timeTaken } ).reduce(0, +) / max(1, Double(testSession.results.filter( { $0.answeredCorrectly && $0.question.type.isScoreQuestion } ).count))
        
        return result > 0 ? result : nil
    }
    
    func getAverageRollAnswerTime() -> Double? {
        guard let testSession = self.testSession, !testSession.results.isEmpty else { return nil }
        
        let result = testSession.results.filter( { $0.answeredCorrectly && !$0.question.type.isScoreQuestion } ).compactMap( { $0.timeTaken } ).reduce(0, +) / max(1, Double(testSession.results.filter( { $0.answeredCorrectly && !$0.question.type.isScoreQuestion } ).count))
        
        return result > 0 ? result : nil
    }
    
    func calculatePercentageIncrease(from value1: Double, to value2: Double) -> Double? {
        guard value1 > 0, value1 < value2 else { return nil }
        
        return 100 * (value2 - value1) / value1
    }
    
    private func calculateIsLastQuestion() -> Bool {
        return self.currentQuestionIndex + 1 == self.testSession?.questionCount
    }
    
    private func setTestQuestionData(_ currentQuestionIndex: Int) {
        guard currentQuestionIndex < self.testQuestionData.count else { return }
        
        self.currentQuestionData = self.testQuestionData[currentQuestionIndex]
    }
    
    private func generateTestQuestionData() {
        guard let testQuestions = self.testSession?.questions else { return }
        
        var testQuestionData: [(BarViewModel?, (RollViewModel, IntervalLinesViewModel)?, [Answer]?)?] = []
        
        var scoreTwoNoteIntervalIdentificationIndicesLeft: [Int] = [0, 1, 2]
        var scoreThreeNoteInnerIntervalsIdentificationIndicesLeft: [Int] = [3, 4, 5]
        var scoreThreeNoteOuterIntervalIdentificationIndicesLeft: [Int] = [6, 7, 8]
        var scoreChordsAreInversionsIndicesLeft: [Int] = [9, 10, 11]
        var scoreTwoNoteIntervalsAreEqualIndicesLeft: [Int] = [12, 13, 14]
        
        for question in testQuestions {
            var rollViewModel: RollViewModel?
            var answer: [Answer]?
            
            switch question.type {
            case .ScoreTwoNoteIntervalIdentification:
                guard !scoreTwoNoteIntervalIdentificationIndicesLeft.isEmpty, let index = scoreTwoNoteIntervalIdentificationIndicesLeft.randomElement() else { testQuestionData.append(nil); break }
                
                let barViewModel = BarViewModel(
                    bar: TestingViewModel.testQuestions[index].0,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                testQuestionData.append((barViewModel, nil, TestingViewModel.testQuestions[index].1))
                scoreTwoNoteIntervalIdentificationIndicesLeft.removeAll(where: { $0 == index } )
            case .ScoreThreeNoteInnerIntervalsIdentification:
                guard !scoreThreeNoteInnerIntervalsIdentificationIndicesLeft.isEmpty, let index = scoreThreeNoteInnerIntervalsIdentificationIndicesLeft.randomElement() else { testQuestionData.append(nil); break }
                
                let barViewModel = BarViewModel(
                    bar: TestingViewModel.testQuestions[index].0,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                testQuestionData.append((barViewModel, nil, TestingViewModel.testQuestions[index].1))
                scoreThreeNoteInnerIntervalsIdentificationIndicesLeft.removeAll(where: { $0 == index } )
            case .ScoreThreeNoteOuterIntervalIdentification:
                guard !scoreThreeNoteOuterIntervalIdentificationIndicesLeft.isEmpty, let index = scoreThreeNoteOuterIntervalIdentificationIndicesLeft.randomElement() else { testQuestionData.append(nil); break }
                
                let barViewModel = BarViewModel(
                    bar: TestingViewModel.testQuestions[index].0,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                testQuestionData.append((barViewModel, nil, TestingViewModel.testQuestions[index].1))
                scoreThreeNoteOuterIntervalIdentificationIndicesLeft.removeAll(where: { $0 == index } )
            case .ScoreChordsAreInversions:
                guard !scoreChordsAreInversionsIndicesLeft.isEmpty, let index = scoreChordsAreInversionsIndicesLeft.randomElement() else { testQuestionData.append(nil); break }
                
                let barViewModel = BarViewModel(
                    bar: TestingViewModel.testQuestions[index].0,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                testQuestionData.append((barViewModel, nil, TestingViewModel.testQuestions[index].1))
                scoreChordsAreInversionsIndicesLeft.removeAll(where: { $0 == index } )
            case .ScoreTwoNoteIntervalsAreEqual:
                guard !scoreTwoNoteIntervalsAreEqualIndicesLeft.isEmpty, let index = scoreTwoNoteIntervalsAreEqualIndicesLeft.randomElement() else { testQuestionData.append(nil); break }
                
                let barViewModel = BarViewModel(
                    bar: TestingViewModel.testQuestions[index].0,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                testQuestionData.append((barViewModel, nil, TestingViewModel.testQuestions[index].1))
                scoreTwoNoteIntervalsAreEqualIndicesLeft.removeAll(where: { $0 == index } )
            case .RollTwoNoteIntervalIdentification:
                switch question.intervalLinesType {
                case .None:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[15].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[15].1
                case .Lines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[16].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[16].1
                case .InvertedLines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[17].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[17].1
                }
            case .RollThreeNoteInnerIntervalsIdentification:
                switch question.intervalLinesType {
                case .None:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[18].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[18].1
                case .Lines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[19].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[19].1
                case .InvertedLines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[20].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[20].1
                }
            case .RollThreeNoteOuterIntervalIdentification:
                switch question.intervalLinesType {
                case .None:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[21].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[21].1
                case .Lines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[22].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[22].1
                case .InvertedLines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[23].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[23].1
                }
            case .RollChordsAreInversions:
                switch question.intervalLinesType {
                case .None:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[24].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[24].1
                case .Lines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[25].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[25].1
                case .InvertedLines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[26].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[26].1
                }
            case .RollTwoNoteIntervalsAreEqual:
                switch question.intervalLinesType {
                case .None:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[27].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[27].1
                case .Lines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[28].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[28].1
                case .InvertedLines:
                    rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [Part(bars: [[TestingViewModel.testQuestions[29].0]])], octaves: 2)
                    answer = TestingViewModel.testQuestions[29].1
                }
            default:
                break
            }
            
            if let rollViewModel = rollViewModel,
               let answer = answer {
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .all,
                    showMelodicIntervalLines: false,
                    barIndex: 0, barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedHarmonicIntervalLineColors : RollViewModel.harmonicIntervalLineColors,
                    melodicIntervalLineColors: [],
                    viewableMelodicLines: [],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: true
                )
                
                testQuestionData.append((nil, (rollViewModel, intervalLinesViewModel), answer))
            }
        }
        
        guard testQuestionData.count == testQuestions.count else { return }
        
        self.testQuestionData = testQuestionData
    }
    
    private func randomlyGenerateQuestionData(question: Question?) {
        guard let question = question else { self.currentQuestionData = nil; return }
        
        let key: Bar.KeySignature = Bar.KeySignature.allCases.randomElement() ?? .CMajor
        let bar = Bar(chords: [Chord(notes: [])], clef: .Treble, timeSignature: .custom(beats: 4, noteValue: 4), repeat: nil, doubleLine: false, keySignature: key)
        let lowestStartingNote = Note(
            pitch: .C,
            octave: question.type.isScoreQuestion ? .oneLine : .subContra,
            duration: .quarter,
            isRest: false,
            isDotted: false,
            hasAccent: false
        )
        
        switch question.type {
        case .ScoreTwoNoteIntervalIdentification, .RollTwoNoteIntervalIdentification:
            let lowestNote = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .half,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .half,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let lowestNoteSemitoneIncrease = Int.random(in: 0...11)
            let highestNoteSemitoneIncrease = Int.random(in: (lowestNoteSemitoneIncrease + 1)...(lowestNoteSemitoneIncrease + 12))
            let answer = Answer(semitones: highestNoteSemitoneIncrease - lowestNoteSemitoneIncrease)
            
            for _ in 0..<lowestNoteSemitoneIncrease {
                lowestNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<highestNoteSemitoneIncrease {
                highestNote.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote)
            bar.chords[0].notes.append(highestNote)
            bar.chords.append(Chord(notes: [TestingViewModel.halfRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [], 
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .all,
                    showMelodicIntervalLines: false,
                    barIndex: 0, 
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedHarmonicIntervalLineColors : RollViewModel.harmonicIntervalLineColors,
                    melodicIntervalLineColors: [],
                    viewableMelodicLines: [],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines, 
                    testing: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreThreeNoteInnerIntervalsIdentification, .RollThreeNoteInnerIntervalsIdentification:
            let lowestNote = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .half,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let middleNote = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .half,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .half,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let lowestNoteSemitoneIncrease = Int.random(in: 0...11)
            let highestNoteSemitoneIncrease = Int.random(in: (lowestNoteSemitoneIncrease + 4)...(lowestNoteSemitoneIncrease + 12))
            let middleNoteSemitoneIncrease = Int.random(in: (lowestNoteSemitoneIncrease + 1)...(highestNoteSemitoneIncrease - 1))
            let answer1 = Answer(semitones: middleNoteSemitoneIncrease - lowestNoteSemitoneIncrease)
            let answer2 = Answer(semitones: highestNoteSemitoneIncrease - middleNoteSemitoneIncrease)
            
            for _ in 0..<lowestNoteSemitoneIncrease {
                lowestNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<middleNoteSemitoneIncrease {
                middleNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<highestNoteSemitoneIncrease {
                highestNote.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote)
            bar.chords[0].notes.append(middleNote)
            bar.chords[0].notes.append(highestNote)
            bar.chords.append(Chord(notes: [TestingViewModel.halfRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer1 = answer1,
                   let answer2 = answer2 {
                    self.currentQuestionData = (barViewModel, nil, [answer1, answer2])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .all,
                    showMelodicIntervalLines: false,
                    barIndex: 0, 
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedHarmonicIntervalLineColors : RollViewModel.harmonicIntervalLineColors,
                    melodicIntervalLineColors: [],
                    viewableMelodicLines: [],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: true
                )
                
                if let answer1 = answer1,
                   let answer2 = answer2 {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer1, answer2])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreThreeNoteOuterIntervalIdentification, .RollThreeNoteOuterIntervalIdentification:
            let lowestNote = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .half,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let middleNote = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .half,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .half,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let lowestNoteSemitoneIncrease = Int.random(in: 0...11)
            let highestNoteSemitoneIncrease = Int.random(in: (lowestNoteSemitoneIncrease + 4)...(lowestNoteSemitoneIncrease + 12))
            let middleNoteSemitoneIncrease = Int.random(in: (lowestNoteSemitoneIncrease + 1)...(highestNoteSemitoneIncrease - 1))
            let answer = Answer(semitones: highestNoteSemitoneIncrease - lowestNoteSemitoneIncrease)
            
            for _ in 0..<lowestNoteSemitoneIncrease {
                lowestNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<middleNoteSemitoneIncrease {
                middleNote.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<highestNoteSemitoneIncrease {
                highestNote.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote)
            bar.chords[0].notes.append(middleNote)
            bar.chords[0].notes.append(highestNote)
            bar.chords.append(Chord(notes: [TestingViewModel.halfRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .all,
                    showMelodicIntervalLines: false,
                    barIndex: 0, 
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedHarmonicIntervalLineColors : RollViewModel.harmonicIntervalLineColors,
                    melodicIntervalLineColors: [],
                    viewableMelodicLines: [],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreChordsAreInversions, .RollChordsAreInversions:
            let lowestNote1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let middleNote1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let lowestNote2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let middleNote2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let lowestNoteSemitoneIncrease = Int.random(in: 0...4)
            let highestNoteSemitoneIncrease = ((lowestNoteSemitoneIncrease + 4)...(lowestNoteSemitoneIncrease + 7)).filter { $0 != lowestNoteSemitoneIncrease + 12 }.randomElement() ?? Int.random(in: (lowestNoteSemitoneIncrease + 4)...(lowestNoteSemitoneIncrease + 7))
            let middleNoteSemitoneIncrease = Int.random(in: (lowestNoteSemitoneIncrease + 2)...(highestNoteSemitoneIncrease - 2))
            
            for _ in 0..<lowestNoteSemitoneIncrease {
                lowestNote1.increaseSemitone(sharps: key.sharps)
                lowestNote2.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<middleNoteSemitoneIncrease {
                middleNote1.increaseSemitone(sharps: key.sharps)
                middleNote2.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<highestNoteSemitoneIncrease {
                highestNote1.increaseSemitone(sharps: key.sharps)
                highestNote2.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote1)
            bar.chords[0].notes.append(middleNote1)
            bar.chords[0].notes.append(highestNote1)
            bar.chords.append(Chord(notes: [TestingViewModel.quarterRest]))
            bar.chords.append(Chord(notes: []))
            
            if Bool.random() { // Apply 1st or 2nd inversion
                lowestNote2.increaseOctave()
            } else {
                lowestNote2.increaseOctave()
                middleNote2.increaseOctave()
            }
            
            let answer = Answer(boolValue: Bool.random())
            
            if answer == .False {
                let semitonesToAdjust = Int.random(in: 1...2) * (Bool.random() ? 1 : -1)
                
                if Bool.random() { // Adjust lowest note
                    if semitonesToAdjust > 0 {
                        for _ in 0..<semitonesToAdjust {
                            lowestNote2.increaseSemitone(sharps: key.sharps)
                        }
                    } else {
                        for _ in 0..<abs(semitonesToAdjust) {
                            lowestNote2.decreaseSemitone(sharps: key.sharps)
                        }
                    }
                } else { // Adjust middle note
                    if semitonesToAdjust > 0 {
                        for _ in 0..<semitonesToAdjust {
                            middleNote2.increaseSemitone(sharps: key.sharps)
                        }
                    } else {
                        for _ in 0..<abs(semitonesToAdjust) {
                            middleNote2.decreaseSemitone(sharps: key.sharps)
                        }
                    }
                }
            }
            
            bar.chords[2].notes.append(lowestNote2)
            bar.chords[2].notes.append(middleNote2)
            bar.chords[2].notes.append(highestNote2)
            bar.chords.append(Chord(notes: [TestingViewModel.quarterRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .all,
                    showMelodicIntervalLines: false,
                    barIndex: 0, 
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedHarmonicIntervalLineColors : RollViewModel.harmonicIntervalLineColors,
                    melodicIntervalLineColors: [],
                    viewableMelodicLines: [],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreTwoNoteIntervalsAreEqual, .RollTwoNoteIntervalsAreEqual:
            let lowestNote1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let lowestNote2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let highestNote2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let lowestNoteSemitoneIncrease = Int.random(in: 2...11)
            let highestNoteSemitoneIncrease = Int.random(in: (lowestNoteSemitoneIncrease + 3)...(lowestNoteSemitoneIncrease + 12))
            
            for _ in 0..<lowestNoteSemitoneIncrease {
                lowestNote1.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<highestNoteSemitoneIncrease {
                highestNote1.increaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(lowestNote1)
            bar.chords[0].notes.append(highestNote1)
            bar.chords.append(Chord(notes: [TestingViewModel.quarterRest]))
            bar.chords.append(Chord(notes: []))
            
            let answer = Answer(boolValue: Bool.random())
            let lowestNote2SemitoneIncrease = (2...11).filter { $0 != lowestNoteSemitoneIncrease }.randomElement() ?? Int.random(in: 0...11)
            let highestNote2SemitoneIncrease = lowestNote2SemitoneIncrease + highestNoteSemitoneIncrease - lowestNoteSemitoneIncrease
            
            for _ in 0..<lowestNote2SemitoneIncrease {
                lowestNote2.increaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<highestNote2SemitoneIncrease {
                highestNote2.increaseSemitone(sharps: key.sharps)
            }
            
            if answer == .False {
                let semitonesToAdjust = Int.random(in: 1...2) * (Bool.random() ? 1 : -1)
                
                if semitonesToAdjust > 0 {
                    for _ in 0..<semitonesToAdjust {
                        highestNote2.increaseSemitone(sharps: key.sharps)
                    }
                } else {
                    for _ in 0..<abs(semitonesToAdjust) {
                        highestNote2.decreaseSemitone(sharps: key.sharps)
                    }
                }
            }
            
            bar.chords[2].notes.append(lowestNote2)
            bar.chords[2].notes.append(highestNote2)
            bar.chords.append(Chord(notes: [TestingViewModel.quarterRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .all,
                    showMelodicIntervalLines: false,
                    barIndex: 0, 
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedHarmonicIntervalLineColors : RollViewModel.harmonicIntervalLineColors,
                    melodicIntervalLineColors: [],
                    viewableMelodicLines: [],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreMelodicIntervalIdentification, .RollMelodicIntervalIdentification:
            let note1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note1SemitoneIncrease = Int.random(in: 0...18)
            let note2SemitoneIncrease = (0...18).filter( { $0 != note1SemitoneIncrease } ).randomElement() ?? Int.random(in: 0...18)
            let answer = Answer(semitones: (note2SemitoneIncrease - note1SemitoneIncrease).trueModulo(12))
            
            for _ in 0..<abs(note1SemitoneIncrease) {
                note1SemitoneIncrease > 0 ? note1.increaseSemitone(sharps: key.sharps) : note1.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note2SemitoneIncrease) {
                note2SemitoneIncrease > 0 ? note2.increaseSemitone(sharps: key.sharps) : note2.decreaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(note1)
            bar.chords.append(Chord(notes: [TestingViewModel.quarterRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[2].notes.append(note2)
            bar.chords.append(Chord(notes: [TestingViewModel.quarterRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .none,
                    showMelodicIntervalLines: true,
                    barIndex: 0,
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: [],
                    melodicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedMelodicIntervalLineColors : RollViewModel.melodicIntervalLineColors,
                    viewableMelodicLines: [part],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: false
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreSmallestMelodicIntervalIdentification, .RollSmallestMelodicIntervalIdentification:
            let note1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note3 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note4 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note1SemitoneIncrease = Int.random(in: 0...18)
            let note2SemitoneIncrease = (0...18).filter( { $0 != note1SemitoneIncrease && ($0 - note1SemitoneIncrease).trueModulo(12) != 0 } ).randomElement() ?? Int.random(in: 0...18)
            let note3SemitoneIncrease = (0...18).filter( { $0 != note2SemitoneIncrease && ($0 - note2SemitoneIncrease).trueModulo(12) != 0} ).randomElement() ?? Int.random(in: 0...18)
            let note4SemitoneIncrease = (0...18).filter( { $0 != note3SemitoneIncrease && ($0 - note3SemitoneIncrease).trueModulo(12) != 0} ).randomElement() ?? Int.random(in: 0...18)
            let answer = Answer(semitones: [(note2SemitoneIncrease - note1SemitoneIncrease).trueModulo(12), (note3SemitoneIncrease - note2SemitoneIncrease).trueModulo(12), (note4SemitoneIncrease - note3SemitoneIncrease).trueModulo(12)].min(by: { $0 < $1 } ))
            
            for _ in 0..<abs(note1SemitoneIncrease) {
                note1SemitoneIncrease > 0 ? note1.increaseSemitone(sharps: key.sharps) : note1.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note2SemitoneIncrease) {
                note2SemitoneIncrease > 0 ? note2.increaseSemitone(sharps: key.sharps) : note2.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note3SemitoneIncrease) {
                note3SemitoneIncrease > 0 ? note3.increaseSemitone(sharps: key.sharps) : note3.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note4SemitoneIncrease) {
                note4SemitoneIncrease > 0 ? note4.increaseSemitone(sharps: key.sharps) : note4.decreaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(note1)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[2].notes.append(note2)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[4].notes.append(note3)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[6].notes.append(note4)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .none,
                    showMelodicIntervalLines: true,
                    barIndex: 0,
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: [],
                    melodicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedMelodicIntervalLineColors : RollViewModel.melodicIntervalLineColors,
                    viewableMelodicLines: [part],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: false
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreLargestMelodicIntervalIdentification, .RollLargestMelodicIntervalIdentification:
            let note1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note3 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note4 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note1SemitoneIncrease = Int.random(in: 0...18)
            let note2SemitoneIncrease = (0...18).filter( { $0 != note1SemitoneIncrease && ($0 - note1SemitoneIncrease).trueModulo(12) != 0} ).randomElement() ?? Int.random(in: 0...18)
            let note3SemitoneIncrease = (0...18).filter( { $0 != note2SemitoneIncrease && ($0 - note2SemitoneIncrease).trueModulo(12) != 0} ).randomElement() ?? Int.random(in: 0...18)
            let note4SemitoneIncrease = (0...18).filter( { $0 != note3SemitoneIncrease && ($0 - note3SemitoneIncrease).trueModulo(12) != 0} ).randomElement() ?? Int.random(in: 0...18)
            let answer = Answer(semitones: [(note2SemitoneIncrease - note1SemitoneIncrease).trueModulo(12), (note3SemitoneIncrease - note2SemitoneIncrease).trueModulo(12), (note4SemitoneIncrease - note3SemitoneIncrease).trueModulo(12)].max(by: { $0 < $1 } ))
            
            for _ in 0..<abs(note1SemitoneIncrease) {
                note1SemitoneIncrease > 0 ? note1.increaseSemitone(sharps: key.sharps) : note1.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note2SemitoneIncrease) {
                note2SemitoneIncrease > 0 ? note2.increaseSemitone(sharps: key.sharps) : note2.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note3SemitoneIncrease) {
                note3SemitoneIncrease > 0 ? note3.increaseSemitone(sharps: key.sharps) : note3.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note4SemitoneIncrease) {
                note4SemitoneIncrease > 0 ? note4.increaseSemitone(sharps: key.sharps) : note4.decreaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(note1)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[2].notes.append(note2)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[4].notes.append(note3)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[6].notes.append(note4)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .none,
                    showMelodicIntervalLines: true,
                    barIndex: 0,
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: [],
                    melodicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedMelodicIntervalLineColors : RollViewModel.melodicIntervalLineColors,
                    viewableMelodicLines: [part],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: false
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreMelodicIntervalInversionIdentification, .RollMelodicIntervalInversionIdentification:
            let note1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .quarter,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note1SemitoneIncrease = Int.random(in: 0...18)
            let note2SemitoneIncrease = (0...18).filter( { $0 != note1SemitoneIncrease } ).randomElement() ?? Int.random(in: 0...18)
            let answer = Answer(semitones: 12 - (note2SemitoneIncrease - note1SemitoneIncrease).trueModulo(12))
            
            for _ in 0..<abs(note1SemitoneIncrease) {
                note1SemitoneIncrease > 0 ? note1.increaseSemitone(sharps: key.sharps) : note1.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note2SemitoneIncrease) {
                note2SemitoneIncrease > 0 ? note2.increaseSemitone(sharps: key.sharps) : note2.decreaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(note1)
            bar.chords.append(Chord(notes: [TestingViewModel.quarterRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[2].notes.append(note2)
            bar.chords.append(Chord(notes: [TestingViewModel.quarterRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .none,
                    showMelodicIntervalLines: true,
                    barIndex: 0,
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: [],
                    melodicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedMelodicIntervalLineColors : RollViewModel.melodicIntervalLineColors,
                    viewableMelodicLines: [part],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: false
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        case .ScoreMelodicMovementIdentification, .RollMelodicMovementIdentification:
            let note1 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note2 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note3 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note4 = Note(
                pitch: lowestStartingNote.pitch,
                octave: lowestStartingNote.octave,
                duration: .eighth,
                isRest: false,
                isDotted: false,
                hasAccent: false
            )
            
            let note1SemitoneIncrease = Int.random(in: 0...18)
            let note2SemitoneIncrease = (0...18).filter( { $0 != note1SemitoneIncrease } ).randomElement() ?? Int.random(in: 0...18)
            let note3SemitoneIncrease = (0...18).filter( { $0 != note2SemitoneIncrease } ).randomElement() ?? Int.random(in: 0...18)
            let note4SemitoneIncrease = (0...18).filter( { $0 != note3SemitoneIncrease && ($0 - note1SemitoneIncrease).trueModulo(12) != 0} ).randomElement() ?? Int.random(in: 0...18)
            let answer = Answer(semitones: (note4SemitoneIncrease - note1SemitoneIncrease).trueModulo(12))
            
            for _ in 0..<abs(note1SemitoneIncrease) {
                note1SemitoneIncrease > 0 ? note1.increaseSemitone(sharps: key.sharps) : note1.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note2SemitoneIncrease) {
                note2SemitoneIncrease > 0 ? note2.increaseSemitone(sharps: key.sharps) : note2.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note3SemitoneIncrease) {
                note3SemitoneIncrease > 0 ? note3.increaseSemitone(sharps: key.sharps) : note3.decreaseSemitone(sharps: key.sharps)
            }
            
            for _ in 0..<abs(note4SemitoneIncrease) {
                note4SemitoneIncrease > 0 ? note4.increaseSemitone(sharps: key.sharps) : note4.decreaseSemitone(sharps: key.sharps)
            }
            
            bar.chords[0].notes.append(note1)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[2].notes.append(note2)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[4].notes.append(note3)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            bar.chords.append(Chord(notes: []))
            bar.chords[6].notes.append(note4)
            bar.chords.append(Chord(notes: [TestingViewModel.eighthRest]))
            
            if question.type.isScoreQuestion {
                let barViewModel = BarViewModel(
                    bar: bar,
                    ledgerLines: 5,
                    showClef: true,
                    showKey: true,
                    showTime: true
                )
                
                if let answer = answer {
                    self.currentQuestionData = (barViewModel, nil, [answer])
                } else {
                    self.currentQuestionData = nil
                }
            } else {
                let part = Part(bars: [[bar]])
                let rollViewModel = RollViewModel(scoreManager: ScoreManager(), parts: [part], octaves: 2)
                
                let intervalLinesViewModel = IntervalLinesViewModel(
                    segments: rollViewModel.segments ?? [],
                    parts: rollViewModel.parts ?? [],
                    groups: rollViewModel.partGroups,
                    harmonicIntervalLinesType: .none,
                    showMelodicIntervalLines: true,
                    barIndex: 0,
                    barWidth: .zero,
                    rowWidth: .zero,
                    rowHeight: .zero,
                    harmonicIntervalLineColors: [],
                    melodicIntervalLineColors: question.intervalLinesType == .InvertedLines ? RollViewModel.invertedMelodicIntervalLineColors : RollViewModel.melodicIntervalLineColors,
                    viewableMelodicLines: [part],
                    showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                    showZigZags: question.intervalLinesType == .InvertedLines,
                    testing: false
                )
                
                if let answer = answer {
                    self.currentQuestionData = (nil, (rollViewModel, intervalLinesViewModel), [answer])
                } else {
                    self.currentQuestionData = nil
                }
            }
        }
    }
    
    static let eighthRest = Note(
        duration: .eighth,
        isRest: true,
        isDotted: false,
        hasAccent: false
    )
    
    static let quarterRest = Note(
        duration: .quarter,
        isRest: true,
        isDotted: false,
        hasAccent: false
    )
    
    static let halfRest = Note(
        duration: .half,
        isRest: true,
        isDotted: false,
        hasAccent: false
    )
    
    static let testQuestions: [(Bar, [Answer])] = [
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .BMajor
        ), [.Tritone]), // S2II 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .B,
                        accidental: .Flat,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .BFlatMajor
        ), [.Minor6th]), // S2II 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .DMajor
        ), [.Minor3rd, .Major6th]), // S3II 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .GMajor
        ), [.Minor3rd, .Tritone]), // S3II 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .G,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .EMajor
        ), [.Perfect4th]), // S3OI 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .E,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .FMajor
        ), [.Major7th]), // S3OI 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .G,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .AMajor
        ), [.False]), // SCAI 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .B,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .B,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .BFlatMajor
        ), [.True]), // SCAI 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .D,
                        accidental: .Flat,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .G,
                        accidental: .Flat,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CFlatMajor
        ), [.True]), // S2SI 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .A,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .EMajor
        ), [.False]), // S2SI 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Minor7th]), // R2II L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Perfect5th]), // R2II IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Major3rd, .Minor3rd]), // R3II L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .A,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Perfect4th, .Perfect5th]), // R3II IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Major7th]), // R3OI L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .G,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .A,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Perfect5th]), // R3OI IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .contra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.False]), // RCAI L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .contra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.True]), // RCAI IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .contra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .G,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.False]), // R2SI L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .contra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.True]), // R3SI IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .BFlatMajor
        ), [.Tritone]), // MS2II 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .oneLine,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .GMajor
        ), [.Perfect5th]), // MS2II 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .E,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .B,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .GFlatMajor
        ), [.Minor2nd]), // MS2SII 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .FMajor
        ), [.Perfect5th]), // MS2SII 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .DMajor
        ), [.Major7th]), // MS2LII 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: .Sharp,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: .Sharp,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .EMajor
        ), [.Minor6th]), // MS2LII 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .EFlatMajor
        ), [.Tritone]), // MS2III 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .DMajor
        ), [.Perfect5th]), // MS2III 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: .Flat,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Flat,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .AFlatMajor
        ), [.Major7th]), // MS2OM 1
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .oneLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .twoLine,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .GMajor
        ), [.Major2nd]), // MS2OM 2
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .contra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Tritone]), // MR2II L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    ),
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .half,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    halfRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Perfect5th]), // MR2II IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .contra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .contra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Minor3rd]), // MR2SII L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .contra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .contra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Minor2nd]), // MR2SII IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .E,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .contra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Minor7th]), // MR2LII L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .B,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Major7th]), // MR2LII IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Minor7th]), // MR2III L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .subContra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .contra,
                        duration: .quarter,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    quarterRest
                ])
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Major3rd]), // MR2III IL
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .contra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .G,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .contra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Perfect4th]), // MR2OM L
        (Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: .D,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .A,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .F,
                        accidental: nil,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
                Chord(notes: [
                    Note(
                        pitch: .C,
                        accidental: .Sharp,
                        octave: .subContra,
                        duration: .eighth,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    eighthRest
                ]),
            ],
            clef: .Treble,
            timeSignature: .custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            keySignature: .CMajor
        ), [.Minor7th]), // MR2OM IL
    ]
}
