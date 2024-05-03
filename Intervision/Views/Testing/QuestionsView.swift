//
//  QuestionsView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct QuestionsView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var showErrorAlert: Bool = false
    
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
                        if testingViewModel.testSession != nil {
                            QuestionView(testingViewModel: testingViewModel)
                                .environmentObject(screenSizeViewModel)
                                .frame(width: screenSizeViewModel.screenSize.width, height: screenSizeViewModel.screenSize.height)
                        } else {
                            EmptyView()
                                .onAppear {
                                    self.showErrorAlert = true
                                }
                                .alert("Fatal Error Occurred", isPresented: $showErrorAlert) {
                                    Button {
                                        testingViewModel.presentedView = .Registration
                                    } label: {
                                        Text("OK")
                                    }
                                }
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    QuestionsView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
