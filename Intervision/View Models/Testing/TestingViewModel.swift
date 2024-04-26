//
//  TestingViewModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation
import SwiftUI

class TestingViewModel: ObservableObject {
    var tester: Tester?
    var testSession: TestSession?

    @Published var testerId = ""
    
    @Published var performerSkillLevel = Tester.SkillLevel.None
    @Published var composerSkillLevel = Tester.SkillLevel.None
    @Published var theoristSkillLevel = Tester.SkillLevel.None
    @Published var educatorSkillLevel = Tester.SkillLevel.None
    @Published var developerSkillLevel = Tester.SkillLevel.None
    
    @Published var questionCount = Question.QuestionType.allCases.count * 3
    
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
}

extension TestingViewModel {
    enum PresentedView {
        case Registration
        case Tutorial
        case Practice
        case Questions
        case Results
    }
}
