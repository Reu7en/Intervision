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
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 1.1, height: screenSizeViewModel.screenSize.height / 1.1)
        
        ZStack {
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
                            .equivalentFont(.title2)
                            .equivalentPadding()
                    }
                    .disabled(currentPage == 0)
                    
                    Button {
                        withAnimation(.easeInOut) {
                            currentPage += 1
                        }
                    } label: {
                        Image(systemName: "arrow.right")
                            .equivalentFont(.title2)
                            .equivalentPadding()
                    }
                    .disabled(currentPage == 4)
                }
                
                Button {
                    withAnimation(.easeInOut) {
                        showPracticeAlert = true
                    }
                } label: {
                    Text("Start Tests")
                        .equivalentFont(.title2)
                        .equivalentPadding()
                }
                .disabled(currentPage != 4)
                .alert("Would you like to complete some practice questions?", isPresented: $showPracticeAlert) {
                    Button {
                        testingViewModel.practice = true
                        
                        testingViewModel.startTests()
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
            .overlay(alignment: .topLeading) {
                Button {
                    withAnimation(.easeInOut) {
                        testingViewModel.presentedView = .Registration
                    }
                } label: {
                    Image(systemName: "xmark")
                        .equivalentFont()
                        .equivalentPadding()
                }
            }
            .frame(width: viewSize.width, height: viewSize.height)
        }
        .frame(width: viewSize.width, height: viewSize.height)
        .equivalentPadding(50)
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
        .environmentObject(screenSizeViewModel)
        #if os(macOS)
        .scaleEffect(0.75)
        #endif
    }
}

#Preview {
    TutorialView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
