//
//  TutorialView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct TutorialView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var currentPage = 0
    @State private var showPracticeAlert = false
    
    var body: some View {
        VStack {
            switch currentPage {
            case 0:
                Text("Page 1")
            case 1:
                Text("Page 2")
            case 2:
                Text("Page 3")
            case 3:
                Text("Page 4")
            case 4:
                Text("Page 5")
            default:
                Text("")
            }
            
            Spacer()
            
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        currentPage -= 1
                    }
                } label: {
                    Image(systemName: "arrow.left")
                }
                .disabled(currentPage == 0)
                
                Button {
                    withAnimation(.easeInOut) {
                        currentPage += 1
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }
                .disabled(currentPage == 4)
            }
            
            Button {
                withAnimation(.easeInOut) {
                    showPracticeAlert = true
                }
            } label: {
                Text("Start Tests")
                    .font(.title2)
            }
            .disabled(currentPage != 4)
            .alert("Would you like to complete some practice questions?", isPresented: $showPracticeAlert) {
                Button {
                    testingViewModel.practice = true
                } label: {
                    Text("Yes")
                }
                
                Button {
                    testingViewModel.practice = false
                    
                    testingViewModel.startTests()
                } label: {
                    Text("No")
                }
            }
        }
        .padding()
    }
}

#Preview {
    TutorialView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
