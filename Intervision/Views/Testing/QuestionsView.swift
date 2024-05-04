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
        switch testingViewModel.presentedQuestionView {
        case .CountdownTimer:
            CountdownTimerView(testingViewModel: testingViewModel)
                .environmentObject(screenSizeViewModel)
        case .Question:
            if testingViewModel.testSession != nil {
                QuestionView(testingViewModel: testingViewModel)
                    .environmentObject(screenSizeViewModel)
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
    }
}

#Preview {
    QuestionsView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
