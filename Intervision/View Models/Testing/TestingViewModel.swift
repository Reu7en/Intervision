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
    var timer: AnyCancellable?
    
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
        self.countdown = 3
        
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            
            if self.countdown > 1 {
                self.countdown -= 1
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
    
    func generateQuestionData(question: Question) {
        
    }
}
