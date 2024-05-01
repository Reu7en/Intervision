//
//  QuestionView.swift
//  Intervision
//
//  Created by Reuben on 01/05/2024.
//

import SwiftUI

struct QuestionView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var answer1Clicked: TestingViewModel.Answer?
    @State private var answer2Clicked: TestingViewModel.Answer?
    @State private var showEndPracticeAlert: Bool = false
    @State private var showEndSessionAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 10) {
                    if let session = testingViewModel.testSession {
                        let question = session.questions[testingViewModel.currentQuestionIndex]
                        
                        if let questionData = testingViewModel.currentQuestionData,
                           let answers = questionData.2, answers.count == (question.type.isMultipartQuestion ? 2 : 1), !(questionData.0 == nil && questionData.1 == nil) {
                            Text("\(testingViewModel.practice ? "Practice " : "")Question \(testingViewModel.currentQuestionIndex + 1)/\(testingViewModel.practice ? 30 : testingViewModel.questionCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if let barViewModel = questionData.0 {
                                BarView(barViewModel: barViewModel)
                                    .frame(width: geometry.size.width / 1.5, height: geometry.size.height / 4)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Material.ultraThickMaterial)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.gray.opacity(0.2))
                                            }
                                            .shadow(radius: 10)
                                    )
                            } else if let rollViewModel = questionData.1,
                                      let parts = rollViewModel.parts,
                                      let segments = rollViewModel.segments {
                                HStack {
                                    GeometryReader { rollGeometry in
                                        let rows = 36
                                        let rowHeight = rollGeometry.size.height / CGFloat(rows)
                                        let pianoKeysWidth = rollGeometry.size.width / 10
                                        let rollWidth = rollGeometry.size.width - pianoKeysWidth
                                        
                                        PianoKeysView(
                                            geometry: rollGeometry,
                                            octaves: 3,
                                            width: pianoKeysWidth,
                                            rowHeight: rowHeight,
                                            showOctaveLabel: true
                                        )
                                        .frame(width: pianoKeysWidth)
                                        
                                        ZStack {
                                            BarRowsView(
                                                rows: rows,
                                                rowWidth: rollWidth,
                                                rowHeight: rowHeight,
                                                beats: 4
                                            )
                                            
                                            if question.intervalLinesType != .None {
                                                IntervalLinesView(
                                                    intervalLinesViewModel: IntervalLinesViewModel(
                                                        segments: segments,
                                                        parts: parts,
                                                        groups: rollViewModel.partGroups,
                                                        harmonicIntervalLinesType: .all,
                                                        showMelodicIntervalLines: false,
                                                        barIndex: 0,
                                                        barWidth: rollWidth,
                                                        rowWidth: rollWidth,
                                                        rowHeight: rowHeight,
                                                        harmonicIntervalLineColors: rollViewModel.viewableHarmonicIntervalLineColors,
                                                        melodicIntervalLineColors: [],
                                                        viewableMelodicLines: [],
                                                        showInvertedIntervals: question.intervalLinesType == .InvertedLines,
                                                        showZigZags: question.intervalLinesType == .InvertedLines
                                                    )
                                                )
                                            }
                                            
                                            RollBarView(
                                                rollViewModel: rollViewModel,
                                                segments: segments,
                                                barIndex: 0,
                                                barWidth: rollWidth,
                                                rowHeight: rowHeight,
                                                colors: [Color.gray],
                                                showDynamics: false
                                            )
                                        }
                                        .frame(width: rollWidth)
                                        .offset(x: pianoKeysWidth)
                                    }
                                }
                                .allowsHitTesting(false)
                                .frame(width: geometry.size.width / 1.5, height: geometry.size.height / 2.375)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Material.ultraThickMaterial)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .shadow(radius: 10)
                                )
                                
                                if question.intervalLinesType != .None {
                                    HStack {
                                        if question.intervalLinesType == .Lines {
                                            ForEach(0..<12) { i in
                                                LineKeyView(
                                                    color: rollViewModel.viewableHarmonicIntervalLineColors[i],
                                                    label: TestingViewModel.Answer(semitones: i + 1)?.rawValue ?? "",
                                                    showZigZags: false
                                                )
                                                .frame(width: geometry.size.width / 20)
                                            }
                                        } else if question.intervalLinesType == .InvertedLines {
                                            ForEach(0..<11) { i in
                                                if i < 5 {
                                                    LineKeyView(
                                                        color: rollViewModel.viewableHarmonicIntervalLineColors[i],
                                                        label: "\(TestingViewModel.Answer(semitones: i + 1)?.rawValue ?? "")/\(TestingViewModel.Answer(semitones: 11 - i)?.rawValue ?? "")",
                                                        showZigZags: true
                                                    )
                                                    .frame(width: geometry.size.width / 12)
                                                } else if i == 5 {
                                                        LineKeyView(
                                                            color: rollViewModel.viewableHarmonicIntervalLineColors[i],
                                                            label: TestingViewModel.Answer(semitones: i + 1)?.rawValue ?? "",
                                                            showZigZags: false
                                                        )
                                                        .frame(width: geometry.size.width / 12)
                                                        
                                                        LineKeyView(
                                                            color: rollViewModel.viewableHarmonicIntervalLineColors[i + 1],
                                                            label: TestingViewModel.Answer(semitones: i + 7)?.rawValue ?? "",
                                                            showZigZags: false
                                                        )
                                                        .frame(width: geometry.size.width / 12)
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: geometry.size.width / 1.5, height: geometry.size.height / 30)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Material.ultraThickMaterial)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.gray.opacity(0.2))
                                            }
                                            .shadow(radius: 10)
                                    )
                                }
                            } else {
                                Spacer()
                                
                                Text("Error! Question will be excluded from results!")
                                    .font(.largeTitle)
                                    .onAppear {
                                        testingViewModel.questionMarked = true
                                        print("Roll Error")
                                    }
                            }
                            
                            Text(testingViewModel.answerTime >= testingViewModel.maximumAnswerTime ? "DNF" : "\(testingViewModel.answerTime, format: .number.rounded(increment: 0.01))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .monospacedDigit()
                                .foregroundStyle(testingViewModel.answerTime >= testingViewModel.maximumAnswerTime ? Color.red : Color.primary)
                            
                            if testingViewModel.questionMarked {
                                NextQuestionButton(testingViewModel: testingViewModel)
                                    .frame(height: geometry.size.height / 30)
                                    .disabled(!testingViewModel.questionMarked)
                                    .padding()
                            } else {
                                AnswerTimerView(testingViewModel: testingViewModel)
                                    .frame(width: geometry.size.width / 1.5, height: geometry.size.height / 30)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Material.ultraThickMaterial)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.gray.opacity(0.2))
                                            }
                                            .shadow(radius: 10)
                                    )
                            }
                            
                            VStack {
                                Text(question.type.description[0])
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(question.type.description[1])
                                    .font(.title3)
                                
                                HStack {
                                    ForEach(TestingViewModel.Answer.allCases.filter( { $0.isBoolQuestion == question.type.isBoolQuestion } ), id: \.self) { answer in
                                        Button {
                                            withAnimation(.easeInOut) {
                                                if self.answer1Clicked == nil {
                                                    self.answer1Clicked = answer
                                                }
                                                
                                                testingViewModel.submitAnswer(questionData: questionData, answer: answer, answerIndex: 0)
                                            }
                                        } label: {
                                            Text("\(answer.rawValue)")
                                                .font(.headline)
                                                .padding()
                                        }
                                        .disabled((self.answer1Clicked != nil && !(answer == answers[0] || answer == self.answer1Clicked)) || testingViewModel.questionMarked)
                                        .allowsHitTesting(self.answer1Clicked == nil)
                                        .background {
                                            if self.answer1Clicked != nil {
                                                if answer == answers[0] {
                                                    Color.green
                                                } else if answer == self.answer1Clicked {
                                                    Color.red
                                                }
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                
                                if question.type.isMultipartQuestion {
                                    Text(question.type.description[2])
                                        .font(.title3)
                                    
                                    HStack {
                                        ForEach(TestingViewModel.Answer.allCases.filter( { $0.isBoolQuestion == question.type.isBoolQuestion } ), id: \.self) { answer in
                                            Button {
                                                withAnimation(.easeInOut) {
                                                    if self.answer2Clicked == nil {
                                                        self.answer2Clicked = answer
                                                    }
                                                    
                                                    testingViewModel.submitAnswer(questionData: questionData, answer: answer, answerIndex: 1)
                                                }
                                            } label: {
                                                Text("\(answer.rawValue)")
                                                    .font(.headline)
                                                    .padding()
                                            }
                                            .disabled((self.answer2Clicked != nil && !(answer == answers[1] || answer == self.answer2Clicked)) || testingViewModel.questionMarked)
                                            .allowsHitTesting(self.answer2Clicked == nil)
                                            .background {
                                                if self.answer2Clicked != nil {
                                                    if answer == answers[1] {
                                                        Color.green
                                                    } else if answer == self.answer2Clicked {
                                                        Color.red
                                                    }
                                                }
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Material.ultraThickMaterial)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                    .shadow(radius: 10)
                            )
                        } else {
                            Spacer()
                            
                            Text("Error! Question will be excluded from results!")
                                .font(.largeTitle)
                                .onAppear {
                                    testingViewModel.questionMarked = true
                                    print("View Error")
                                }
                        }
                    }
                }
                
                Spacer()
            }
            .overlay(alignment: .topLeading) {
                Button {
                    if testingViewModel.practice {
                        self.showEndPracticeAlert = true
                    } else {
                        self.showEndSessionAlert = true
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .padding()
                }
            }
            .alert("Would you like to stop practicing and start the tests?", isPresented: $showEndPracticeAlert) {
                Button {
                    testingViewModel.practice = false
                    
                    testingViewModel.startTests()
                } label: {
                    Text("Yes")
                }
                
                Button {
                    
                } label: {
                    Text("No")
                }
            }
            .alert("Would you like to end the test and view your results?", isPresented: $showEndSessionAlert) {
                Button {
                    testingViewModel.presentedView = .Results
                } label: {
                    Text("Yes")
                }
                
                Button {
                    
                } label: {
                    Text("No")
                }
            }
        }
    }
}

#Preview {
    QuestionView(testingViewModel: TestingViewModel())
}
