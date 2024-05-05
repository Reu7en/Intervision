//
//  ResultsView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

struct ResultsView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var showExitAlert = false
    
    var body: some View {
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 1.1, height: screenSizeViewModel.screenSize.height / 1.1)
        let cornerRadius = screenSizeViewModel.getEquivalentValue(8)
        let spacing = screenSizeViewModel.getEquivalentValue(20)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(80)
        let buttonWidth = (viewSize.width / 4) - (spacing * 3 / 4)
        
        ZStack {
            VStack(spacing: spacing) {
                if let testSession = testingViewModel.testSession,
                   let totalQuestionsCorrect = testingViewModel.getTotalQuestionsCorrect() {
                    Text("Thank you for completing the test!")
                        .equivalentFont(.title)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    VStack(spacing: spacing) {
                        if let totalPercentageAccuracy = testingViewModel.getTotalPercentageAccuracy() {
                            HStack(spacing: 0) {
                                Text("Correct Answers")
                                    .equivalentFont(.title2)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            
                                HStack(spacing: 0) {
                                    Text("\(totalQuestionsCorrect)/\(testSession.results.count) ")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("(\(totalPercentageAccuracy, format: .number.rounded(increment: 0.01))%) ")
                                        .foregroundStyle(getColor(score: totalPercentageAccuracy))
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(getEmoji(score: totalPercentageAccuracy))")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                        if let scorePercentageAccuracy = testingViewModel.getScorePercentageAccuracy() {
                            if let scoreQuestionsCorrect = testingViewModel.getScoreQuestionsCorrect() {
                                HStack(spacing: 0) {
                                    Text("Correct Score Answers")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 0) {
                                        Text("\(scoreQuestionsCorrect)/\(testSession.results.filter( { $0.question.type.isScoreQuestion } ).count) ")
                                            .equivalentFont(.title2)
                                            .fontWeight(.semibold)
                                        
                                        Text("(\(scorePercentageAccuracy, format: .number.rounded(increment: 0.01))%) ")
                                            .foregroundStyle(getColor(score: scorePercentageAccuracy))
                                            .equivalentFont(.title2)
                                            .fontWeight(.semibold)
                                        
                                        Text("\(getEmoji(score: scorePercentageAccuracy))")
                                            .equivalentFont(.title2)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                        
                        if let rollPercentageAccuracy = testingViewModel.getRollPercentageAccuracy() {
                            if let rollQuestionsCorrect = testingViewModel.getRollQuestionsCorrect() {
                                HStack(spacing: 0) {
                                    Text("Correct Piano Roll Answers")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 0) {
                                        Text("\(rollQuestionsCorrect)/\(testSession.results.filter( { !$0.question.type.isScoreQuestion } ).count) ")
                                            .equivalentFont(.title2)
                                            .fontWeight(.semibold)
                                        
                                        Text("(\(rollPercentageAccuracy, format: .number.rounded(increment: 0.01))%) ")
                                            .foregroundStyle(getColor(score: rollPercentageAccuracy))
                                            .equivalentFont(.title2)
                                            .fontWeight(.semibold)
                                        
                                        Text("\(getEmoji(score: rollPercentageAccuracy))")
                                            .equivalentFont(.title2)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                        
                        if let averageAnswerTime = testingViewModel.getAverageAnswerTime() {
                            HStack(spacing: 0) {
                                Text("Average time to answer a question correctly")
                                    .equivalentFont(.title2)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            
                                HStack(spacing: 0) {
                                    Text("\(averageAnswerTime, format: .number.rounded(increment: 0.01)) ")
                                    .foregroundStyle(getColor(score: 100 * ((60 - averageAnswerTime) / 60)))                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(getEmoji(score: 100 * ((60 - averageAnswerTime) / 60)))")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                        if let averageScoreAnswerTime = testingViewModel.getAverageScoreAnswerTime() {
                            HStack(spacing: 0) {
                                Text("Average time to answer a score question correctly")
                                    .equivalentFont(.title2)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            
                                HStack(spacing: 0) {
                                    Text("\(averageScoreAnswerTime, format: .number.rounded(increment: 0.01)) ")
                                        .foregroundStyle(getColor(score: 100 * ((60 - averageScoreAnswerTime) / 60)))
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(getEmoji(score: 100 * ((60 - averageScoreAnswerTime) / 60)))")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                        if let averageRollAnswerTime = testingViewModel.getAverageRollAnswerTime() {
                            HStack(spacing: 0) {
                                Text("Average time to answer a piano roll question correctly")
                                    .equivalentFont(.title2)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            
                                HStack(spacing: 0) {
                                    Text("\(averageRollAnswerTime, format: .number.rounded(increment: 0.01)) ")
                                        .foregroundStyle(getColor(score: 100 * ((60 - averageRollAnswerTime) / 60)))
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(getEmoji(score: 100 * ((60 - averageRollAnswerTime) / 60)))")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                        if let averageScoreAnswerTime = testingViewModel.getAverageScoreAnswerTime(),
                           let averageRollAnswerTime = testingViewModel.getAverageRollAnswerTime() {
                            if let rollIncrease = testingViewModel.calculatePercentageIncrease(from: averageScoreAnswerTime, to: averageRollAnswerTime) {
                                HStack(spacing: 0) {
                                    Text("You answered piano roll questions correctly ")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(rollIncrease)% ")
                                        .foregroundStyle(getColor(score: rollIncrease * 4))
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("more often that score questions ")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(getEmoji(score: rollIncrease == 25 ? 101 : rollIncrease * 4))")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                }
                            } else if let scoreIncrease = testingViewModel.calculatePercentageIncrease(from: averageRollAnswerTime, to: averageScoreAnswerTime) {
                                HStack(spacing: 0) {
                                    Text("You answered score questions correctly ")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(scoreIncrease)% ")
                                        .foregroundStyle(getColor(score: scoreIncrease * 4))
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("more often that piano roll questions ")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(getEmoji(score: scoreIncrease == 25 ? 101 : scoreIncrease * 4))")
                                        .equivalentFont(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .frame(width: viewSize.width / 2)
                    .equivalentPadding(padding: 50)
                    .background(
                        RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20))
                            .fill(Material.ultraThickMaterial)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            .overlay {
                                RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20))
                                    .fill(Color.gray.opacity(0.2))
                            }
                            .shadow(radius: screenSizeViewModel.getEquivalentValue(10))
                    )
                } else {
                    Spacer()
                    
                    Text("You didn't answer any questions! 😢")
                        .equivalentFont(.title2)
                }
                
                Spacer()
                
                Button {
                    testingViewModel.showSavingEmailAlert.toggle()
                } label: {
                    Text("Save Results")
                        .equivalentFont(.title)
                        .fontWeight(.semibold)
                        .frame(width: buttonWidth, height: buttonHeight * 1.5)
                        .background(Color.accentColor)
                        .cornerRadius(cornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
                .alert(isPresented: $testingViewModel.showSavingSuccessAlert) {
                    Alert(
                        title: Text("Saved"),
                        message: Text("Your test data has been saved successfully! 🎉")
                    )
                }
                .alert(isPresented: $testingViewModel.showSavingErrorAlert) {
                    Alert(
                        title: Text("Error!"),
                        message: Text("Test data has not been saved!")
                    )
                }
                .alert(isPresented: $testingViewModel.showSavingEmailAlert) {
                    Alert(
                        title: Text("Please send your test results to 'Intervision.app@gmail.com'"),
                        message: Text("The email address has been copied to your clipboard"),
                        dismissButton: .default(Text("OK")) {
                            #if os(macOS)
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString("Intervision.app@gmail.com", forType: .string)
                            
                            withAnimation(.easeInOut) {
                                testingViewModel.saveTestSession()
                            }
                            #elseif os(iOS)
                            UIPasteboard.general.string = "Intervision.app@gmail.com"
                            
                            withAnimation(.easeInOut) {
                                testingViewModel.saveTestSession()
                            }
                            #endif
                        }
                    )
                }
                #if os(iOS)
                .sheet(item: $testingViewModel.resultsURL) { identifiableURL in
                    ActivityView(activityItems: [identifiableURL.url])
                }
                #endif
            }
            .frame(width: viewSize.width)
            .overlay(alignment: .topLeading) {
                Button {
                    self.showExitAlert = true
                    
                } label: {
                    Image(systemName: "xmark")
                        .equivalentFont()
                        .equivalentPadding()
                }
            }
            .alert("Are you sure you want to exit?", isPresented: $showExitAlert) {
                Button {
                    withAnimation(.easeInOut) {
                        testingViewModel.presentedView = .Registration
                    }
                } label: {
                    Text("Yes")
                }
                
                Button {
                    
                } label: {
                    Text("No")
                }
            }
        }
        .frame(width: viewSize.width, height: viewSize.height)
        .equivalentPadding(padding: 50)
        .background(
            RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20))
                .fill(Material.ultraThickMaterial)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .overlay {
                    RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20))
                        .fill(Color.gray.opacity(0.2))
                }
                .shadow(radius: screenSizeViewModel.getEquivalentValue(10))
        )
        #if os(macOS)
        .scaleEffect(0.75)
        #endif
    }
    
    private func getColor(score: Double) -> Color {
        return Color(red: 2 * (1 - min(100, score) / 100), green: 2 * min(100, score) / 100, blue: 0)
    }
    
    private func getEmoji(score: Double) -> String {
        return score == 100 ? "💯" : score >= 90 ? "🤯" : score >= 80 ? "🤩" : score >= 70 ? "😎" : score >= 60 ? "🤠" : score >= 50 ? "😁" : score >= 40 ? "😬" : score >= 30 ? "🥲" : score >= 20 ? "😤" : score >= 10 ? "🫣" : "🤨"
    }
}

#Preview {
    ResultsView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
