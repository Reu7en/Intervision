//
//  TestingHomeView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct TestingHomeView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @Binding var presentedHomeView: HomeView.PresentedView
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        switch testingViewModel.presentedView {
        case .Registration:
            TestingRegistrationView(testingViewModel: testingViewModel)
                .environmentObject(screenSizeViewModel)
                .overlay(alignment: .topLeading) {
                    Button {
                        withAnimation(.easeInOut) {
                            presentedHomeView = .None
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .equivalentFont()
                            .equivalentPadding()
                    }
                    .equivalentPadding(.all, padding: 50)
                }
        case .Tutorial:
            TutorialView(testingViewModel: testingViewModel)
                .frame(width: screenSizeViewModel.screenSize.width / 3)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Material.ultraThickMaterial)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.2))
                        }
                )
                .shadow(radius: 10)
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
    TestingHomeView(presentedHomeView: Binding.constant(.None), testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
