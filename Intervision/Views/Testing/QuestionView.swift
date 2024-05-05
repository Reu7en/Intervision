//
//  QuestionView.swift
//  Intervision
//
//  Created by Reuben on 01/05/2024.
//

import SwiftUI

struct QuestionView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var answer1Clicked: TestingViewModel.Answer?
    @State private var answer2Clicked: TestingViewModel.Answer?
    @State private var showEndPracticeAlert = false
    @State private var showEndSessionAlert = false
    @State private var opacity = 1.0
    @State private var intervalLinesOpacity = 1.0
    
    var body: some View {
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 1.05, height: screenSizeViewModel.screenSize.height / 1.05)
        let spacing = screenSizeViewModel.getEquivalentValue(8)
        let cornerRadius = screenSizeViewModel.getEquivalentValue(8)
        let backgroundCornerRadius = screenSizeViewModel.getEquivalentValue(20)
        let backgroundShadow = screenSizeViewModel.getEquivalentValue(10)
        let barHeight = viewSize.height / 2.25
        let timerHeight = viewSize.height / 30
        
        ZStack {
            VStack(spacing: spacing) {
                if let session = testingViewModel.testSession {
                    let question = session.questions[testingViewModel.currentQuestionIndex]
                    
                    if let questionData = testingViewModel.currentQuestionData,
                       let answers = questionData.2, answers.count == (question.type.isMultipartQuestion ? 2 : 1), !(questionData.0 == nil && questionData.1 == nil) {
                        Text("\(testingViewModel.practice ? "Practice Question" : "Question \(testingViewModel.currentQuestionIndex + 1)/\(40)")")
                            .equivalentFont(.title3)
                            .fontWeight(.semibold)
                            .equivalentPadding(.bottom)
                        
                        if let barViewModel = questionData.0 {
                            BarView(barViewModel: barViewModel)
                                .frame(width: viewSize.width, height: barHeight / 1.25)
                                .equivalentPadding(.all, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                        .fill(Material.ultraThin)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .shadow(radius: backgroundShadow)
                                )
                        } else if let viewModels = questionData.1 {
                            ZStack {
                                HStack(spacing: 0) {
                                    let rows = 24
                                    let rowHeight = barHeight / CGFloat(rows)
                                    let pianoKeysWidth = viewSize.width / 10
                                    let inspectorWidth = viewSize.width / 8
                                    let rollWidth = viewSize.width - inspectorWidth - (testingViewModel.showPiano ? pianoKeysWidth : 0)
                                    
                                    ZStack {
                                        HStack(spacing: 0) {
                                            if testingViewModel.showPiano {
                                                PianoKeysView(
                                                    octaves: 2,
                                                    width: pianoKeysWidth,
                                                    rowHeight: rowHeight,
                                                    showOctaveLabel: true,
                                                    fontSize: screenSizeViewModel.getEquivalentValue(16)
                                                )
                                                .frame(width: pianoKeysWidth, height: barHeight)
                                                .transition(.move(edge: .leading))
                                                .border(Color.black)
                                            }
                                            
                                            ZStack {
                                                BarRowsView(
                                                    rows: rows,
                                                    rowWidth: rollWidth,
                                                    rowHeight: rowHeight,
                                                    beats: 4,
                                                    viewType: testingViewModel.rollRowsViewType,
                                                    image: false
                                                )
                                                .transition(.move(edge: .leading))
                                                .background(colorScheme == .light ? Color.black.opacity(0.5) : Color.clear)
                                                
                                                RollBarView(
                                                    rollViewModel: viewModels.0,
                                                    segments: viewModels.0.segments ?? [],
                                                    barIndex: 0,
                                                    barWidth: rollWidth,
                                                    rowHeight: rowHeight,
                                                    colors: [Color.white],
                                                    showDynamics: false
                                                )
                                                .transition(.move(edge: .leading))
                                                .allowsHitTesting(false)
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: backgroundCornerRadius))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                                .stroke(Color.black, lineWidth: screenSizeViewModel.getEquivalentValue(1))
                                                .background(Color.clear)
                                        }
                                        
                                        if question.intervalLinesType != .None {
                                            IntervalLinesView(
                                                intervalLinesViewModel: viewModels.1
                                            )
                                            .onAppear {
                                                viewModels.1.barWidth = rollWidth
                                                viewModels.1.rowWidth = rollWidth
                                                viewModels.1.rowHeight = rowHeight
                                            }
                                            .onChange(of: testingViewModel.showPiano) {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                    viewModels.1.barWidth = rollWidth
                                                    viewModels.1.rowWidth = rollWidth
                                                    viewModels.1.rowHeight = rowHeight
                                                    
                                                    withAnimation(.linear(duration: 0.25)) {
                                                        intervalLinesOpacity = 1.0
                                                    }
                                                }
                                            }
                                            .onChange(of: viewSize) {
                                                withAnimation(.easeInOut) {
                                                    viewModels.1.barWidth = rollWidth
                                                    viewModels.1.rowWidth = rollWidth
                                                    viewModels.1.rowHeight = rowHeight
                                                }
                                            }
                                            .opacity(intervalLinesOpacity)
                                            .offset(x: testingViewModel.showPiano ? pianoKeysWidth : 0)
                                        }
                                    }
                                    
                                    VStack(spacing: spacing) {
                                        Spacer()
                                        
                                        Text("Show Piano")
                                            .equivalentFont(.title3)
                                            .fontWeight(.semibold)
                                        
                                        Button {
                                            withAnimation(.linear(duration: 0.25)) {
                                                intervalLinesOpacity = 0.0
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                    withAnimation(.easeInOut) {
                                                        testingViewModel.showPiano.toggle()
                                                    }
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "pianokeys")
                                                .equivalentFont(.title)
                                                .frame(width: inspectorWidth * 0.75, height: barHeight / 9)
                                                .background(testingViewModel.showPiano ? Color.accentColor : Color.secondary)
                                                .cornerRadius(cornerRadius)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Text("Background")
                                            .equivalentFont(.title3)
                                            .fontWeight(.semibold)
                                        
                                        ForEach(BarRowsView.ViewType.allCases, id: \.self) { viewType in
                                            Button {
                                                withAnimation(.easeInOut) {
                                                    testingViewModel.rollRowsViewType = viewType
                                                }
                                            } label: {
                                                Text(viewType.rawValue)
                                                    .equivalentFont()
                                                    .fontWeight(.semibold)
                                                    .frame(width: inspectorWidth * 0.75, height: barHeight / 9)
                                                    .background(testingViewModel.rollRowsViewType == viewType ? Color.accentColor : Color.secondary)
                                                    .cornerRadius(cornerRadius)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        
                                        Spacer()
                                    }
                                    .frame(width: inspectorWidth)
                                }
                            }
                            .frame(height: barHeight)
                            .equivalentPadding(.all, 30)
                            .background(
                                RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                    .fill(Material.ultraThin)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                    .shadow(radius: backgroundShadow)
                            )
                            
                            if question.intervalLinesType != .None {
                                HStack(spacing: spacing) {
                                    if question.intervalLinesType == .Lines {
                                        ForEach(0..<12) { i in
                                            LineKeyView(
                                                color: RollViewModel.harmonicIntervalLineColors[i],
                                                label: TestingViewModel.Answer(semitones: i + 1)?.rawValue ?? "",
                                                showZigZags: false
                                            )
                                            .environmentObject(screenSizeViewModel)
                                        }
                                    } else if question.intervalLinesType == .InvertedLines {
                                        ForEach(0..<11) { i in
                                            if i < 5 {
                                                LineKeyView(
                                                    color: RollViewModel.invertedHarmonicIntervalLineColors[i],
                                                    label: "\(TestingViewModel.Answer(semitones: i + 1)?.rawValue ?? "")/\(TestingViewModel.Answer(semitones: 11 - i)?.rawValue ?? "")",
                                                    showZigZags: true
                                                )
                                                .environmentObject(screenSizeViewModel)
                                            } else if i == 5 {
                                                LineKeyView(
                                                    color: RollViewModel.invertedHarmonicIntervalLineColors[i],
                                                    label: TestingViewModel.Answer(semitones: i + 1)?.rawValue ?? "",
                                                    showZigZags: false
                                                )
                                                .environmentObject(screenSizeViewModel)
                                                
                                                LineKeyView(
                                                    color: RollViewModel.invertedHarmonicIntervalLineColors[i + 1],
                                                    label: TestingViewModel.Answer(semitones: i + 7)?.rawValue ?? "",
                                                    showZigZags: false
                                                )
                                                .environmentObject(screenSizeViewModel)
                                            }
                                        }
                                    }
                                }
                                .frame(width: viewSize.width, height: timerHeight)
                                .equivalentPadding(.all, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                        .fill(Material.ultraThin)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .shadow(radius: backgroundShadow)
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
                            
                            NextQuestionButton(testingViewModel: testingViewModel)
                                .frame(height: viewSize.height / 30)
                                .disabled(!testingViewModel.questionMarked)
                                .equivalentPadding()
                                .environmentObject(screenSizeViewModel)
                            
                            Spacer()
                        }
                        
                        Text(testingViewModel.answerTime >= testingViewModel.maximumAnswerTime ? "DNF" : "\(testingViewModel.answerTime, format: .number.rounded(increment: 0.01))")
                            .equivalentFont(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(testingViewModel.answerTime >= testingViewModel.maximumAnswerTime ? Color.red : Color.primary)
                        
                        if testingViewModel.questionMarked {
                            NextQuestionButton(testingViewModel: testingViewModel)
                                .frame(height: timerHeight)
                                .equivalentPadding(.all, 30)
                                .disabled(!testingViewModel.questionMarked)
                                .environmentObject(screenSizeViewModel)
                        } else {
                            AnswerTimerView(testingViewModel: testingViewModel)
                                .frame(width: viewSize.width, height: timerHeight)
                                .equivalentPadding(.all, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                        .fill(Material.ultraThin)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .shadow(radius: backgroundShadow)
                                )
                                .environmentObject(screenSizeViewModel)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: spacing) {
                            Text(question.type.description[0])
                                .equivalentFont(.title3)
                                .fontWeight(.semibold)
                            
                            Text(question.type.description[1])
                                .equivalentFont()
                                .fontWeight(.semibold)
                            
                            HStack(spacing: spacing) {
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
                                            .equivalentFont()
                                            .fontWeight(.semibold)
                                            .frame(width: question.type.isBoolQuestion ? viewSize.width / 5 : (viewSize.width / 12) - (spacing) * (11 / 12), height: timerHeight * 1.5)
                                            .background {
                                                if self.answer1Clicked != nil {
                                                    if answer == answers[0] {
                                                        Color.green
                                                    } else if answer == self.answer1Clicked {
                                                        Color.red
                                                    }
                                                } else {
                                                    Color.secondary
                                                }
                                            }
                                            .cornerRadius(cornerRadius)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled((self.answer1Clicked != nil && !(answer == answers[0] || answer == self.answer1Clicked)) || testingViewModel.questionMarked)
                                    .allowsHitTesting(self.answer1Clicked == nil)
                                }
                            }
                            .frame(width: viewSize.width)
                            
                            if question.type.isMultipartQuestion {
                                Text(question.type.description[2])
                                    .equivalentFont()
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: spacing) {
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
                                                .equivalentFont()
                                                .fontWeight(.semibold)
                                                .frame(width: question.type.isBoolQuestion ? viewSize.width / 5 : (viewSize.width / 12) - (spacing) * (11 / 12), height: timerHeight * 1.5)
                                                .background {
                                                    if self.answer2Clicked != nil {
                                                        if answer == answers[1] {
                                                            Color.green
                                                        } else if answer == self.answer2Clicked {
                                                            Color.red
                                                        }
                                                    } else {
                                                        Color.secondary
                                                    }
                                                }
                                                .cornerRadius(cornerRadius)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .disabled((self.answer2Clicked != nil && !(answer == answers[1] || answer == self.answer2Clicked)) || testingViewModel.questionMarked)
                                        .allowsHitTesting(self.answer2Clicked == nil)
                                    }
                                }
                            }
                        }
                        .equivalentPadding(.all, 30)
                        .background(
                            RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                .fill(Material.ultraThick)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                .overlay {
                                    RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                        .fill(Color.gray.opacity(0.2))
                                }
                                .shadow(radius: backgroundShadow)
                        )
                    } else {
                        Spacer()
                        
                        Text("Error! Question will be excluded from results!")
                            .font(.largeTitle)
                            .onAppear {
                                testingViewModel.questionMarked = true
                                print("View Error")
                            }
                        
                        NextQuestionButton(testingViewModel: testingViewModel)
                            .frame(height: viewSize.height / 30)
                            .disabled(!testingViewModel.questionMarked)
                            .padding()
                            .environmentObject(screenSizeViewModel)
                        
                        Spacer()
                    }
                }
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
                        .equivalentFont()
                        .equivalentPadding()
                }
            }
        }
        .frame(width: viewSize.width, height: viewSize.height)
        .alert("Would you like to stop practicing and start the test?", isPresented: $showEndPracticeAlert) {
            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    testingViewModel.questionVisible = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    testingViewModel.practice = false
                    testingViewModel.startTests()
                }
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
        .opacity(testingViewModel.questionVisible ? 1.0 : 0.0)
    }
}

#Preview {
    QuestionView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
        .frame(width: 800, height: 450)
}
