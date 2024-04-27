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
                            case .RollTwoNoteIntervalIdentificationNoLines:
                                RollTwoNoteIntervalIdentificationNoLinesView(testingViewModel: testingViewModel)
                            case .RollTwoNoteIntervalIdentificationWithLines:
                                RollTwoNoteIntervalIdentificationWithLinesView(testingViewModel: testingViewModel)
                            case .RollTwoNoteIntervalIdentificationWithInvertedLines:
                                RollTwoNoteIntervalIdentificationWithInvertedLinesView(testingViewModel: testingViewModel)
                            case .RollThreeNoteInnerIntervalsIdentificationNoLines:
                                RollThreeNoteInnerIntervalsIdentificationNoLinesView(testingViewModel: testingViewModel)
                            case .RollThreeNoteInnerIntervalsIdentificationWithLines:
                                RollThreeNoteInnerIntervalsIdentificationWithLinesView(testingViewModel: testingViewModel)
                            case .RollThreeNoteInnerIntervalsIdentificationWithInvertedLines:
                                RollThreeNoteInnerIntervalsIdentificationWithInvertedLinesView(testingViewModel: testingViewModel)
                            case .RollThreeNoteOuterIntervalIdentificationNoLines:
                                RollThreeNoteOuterIntervalIdentificationNoLinesView(testingViewModel: testingViewModel)
                            case .RollThreeNoteOuterIntervalIdentificationWithLines:
                                RollThreeNoteOuterIntervalIdentificationWithLinesView(testingViewModel: testingViewModel)
                            case .RollThreeNoteOuterIntervalIdentificationWithInvertedLines:
                                RollThreeNoteOuterIntervalIdentificationWithInvertedLinesView(testingViewModel: testingViewModel)
                            case .RollChordsAreInversionsNoLines:
                                RollChordsAreInversionsNoLinesView(testingViewModel: testingViewModel)
                            case .RollChordsAreInversionsWithLines:
                                RollChordsAreInversionsWithLinesView(testingViewModel: testingViewModel)
                            case .RollChordsAreInversionsWithInvertedLines:
                                RollChordsAreInversionsWithInvertedLinesView(testingViewModel: testingViewModel)
                            case .BothTwoNoteChordsAreEqualNoLines:
                                BothTwoNoteChordsAreEqualNoLinesView(testingViewModel: testingViewModel)
                            case .BothTwoNoteChordsAreEqualWithLines:
                                BothTwoNoteChordsAreEqualWithLinesView(testingViewModel: testingViewModel)
                            case .BothTwoNoteChordsAreEqualWithInvertedLines:
                                BothTwoNoteChordsAreEqualWithInvertedLinesView(testingViewModel: testingViewModel)
                            case .BothThreeNoteChordsAreEqualNoLines:
                                BothThreeNoteChordsAreEqualNoLinesView(testingViewModel: testingViewModel)
                            case .BothThreeNoteChordsAreEqualWithLines:
                                BothThreeNoteChordsAreEqualWithLinesView(testingViewModel: testingViewModel)
                            case .BothThreeNoteChordsAreEqualWithInvertedLines:
                                BothThreeNoteChordsAreEqualWithInvertedLinesView(testingViewModel: testingViewModel)
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
