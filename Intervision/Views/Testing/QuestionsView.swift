//
//  QuestionsView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct QuestionsView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    switch testingViewModel.presentedQuestionView {
                    case .CountdownTimer:
                        CountdownTimerView(testingViewModel: testingViewModel)
                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
                    case .Question:
                        if let testSession = testingViewModel.testSession {
                            switch testSession.questions[testingViewModel.currentQuestion].type {
                            case .ScoreTwoNoteIntervalIdentification:
                                ScoreTwoNoteIntervalIdentificationView(testingViewModel: testingViewModel)
                            case .ScoreThreeNoteInnerIntervalsIdentification:
                                ScoreThreeNoteInnerIntervalsIdentificationView(testingViewModel: testingViewModel)
                            case .ScoreThreeNoteOuterIntervalIdentification:
                                ScoreThreeNoteOuterIntervalIdentificationView(testingViewModel: testingViewModel)
                            case .ScoreChordsAreInversions:
                                ScoreChordsAreInversionsView(testingViewModel: testingViewModel)
                            case .ScoreTwoNoteIntervalsAreEqual:
                                ScoreTwoNoteIntervalsAreEqualView(testingViewModel: testingViewModel)
                            case .RollTwoNoteIntervalIdentification:
                                RollTwoNoteIntervalIdentificationView(testingViewModel: testingViewModel)
                            case .RollThreeNoteInnerIntervalsIdentification:
                                RollThreeNoteInnerIntervalsIdentificationView(testingViewModel: testingViewModel)
                            case .RollThreeNoteOuterIntervalIdentification:
                                RollThreeNoteOuterIntervalIdentificationView(testingViewModel: testingViewModel)
                            case .RollChordsAreInversions:
                                RollChordsAreInversionsView(testingViewModel: testingViewModel)
                            case .RollTwoNoteIntervalsAreEqual:
                                RollTwoNoteIntervalsAreEqualView(testingViewModel: testingViewModel)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

#Preview {
    QuestionsView(testingViewModel: TestingViewModel())
}
