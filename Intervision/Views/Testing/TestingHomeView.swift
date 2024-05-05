//
//  TestingHomeView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct TestingHomeView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @Binding var presentedHomeView: HomeView.PresentedView
    
    var body: some View {
        switch testingViewModel.presentedView {
        case .Registration:
            TestingRegistrationView(testingViewModel: testingViewModel, presentedHomeView: $presentedHomeView)
                .environmentObject(screenSizeViewModel)
        case .Tutorial:
            TutorialView(testingViewModel: testingViewModel)
                .environmentObject(screenSizeViewModel)
        case .Questions:
            QuestionsView(testingViewModel: testingViewModel)
                .environmentObject(screenSizeViewModel)
                .navigationBarBackButtonHidden()
        case .Results:
            ResultsView(testingViewModel: testingViewModel)
                .environmentObject(screenSizeViewModel)
                .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    TestingHomeView(testingViewModel: TestingViewModel(), presentedHomeView: Binding.constant(.None))
        .environmentObject(ScreenSizeViewModel())
}
