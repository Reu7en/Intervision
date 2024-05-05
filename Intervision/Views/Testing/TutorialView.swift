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
        let spacing = screenSizeViewModel.getEquivalentValue(20)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(80)
        let buttonWidth = (viewSize.width / 4) - (spacing * 3 / 4)
        let cornerRadius = screenSizeViewModel.getEquivalentValue(8)
        
        ZStack {
            VStack(spacing: spacing) {
                switch currentPage {
                case 0:
                    Image("Tutorial1")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20)))
                        .frame(width: viewSize.width / 1.5, height: viewSize.height / 1.5)
                    
                    Text("The test consists of 40 questions in total, of which there are 10 different types of questions being asked. 5 types of question ask you to identify harmonic qualities in a phrase, while the other 5 ask you to identify melodic qualities in a phrase.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                case 1:
                    Image("Tutorial2")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20)))
                        .frame(width: viewSize.width / 1.5, height: viewSize.height / 1.5)
                    
                    Text("For half of the questions you will be presented with a bar in standard notation which will always be treble clef.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                case 2:
                    Image("Tutorial3")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20)))
                        .frame(width: viewSize.width / 1.5, height: viewSize.height / 1.5)
                    
                    Text("For the other half of the questions you will be presented with a bar in a piano roll style view, which also has coloured lines to better help you identify different intervals.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                case 3:
                    Image("Tutorial4")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20)))
                        .frame(width: viewSize.width / 1.5, height: viewSize.height / 1.5)
                    
                    Text("The colours will always be the same and a colour key will be displayed below the piano roll, but half of these questions will also pair up the inversions of different intervals together with the same line colour and a zig-zag line to differentiate between them.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                case 4:
                    Image("Tutorial5")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20)))
                        .frame(width: viewSize.width / 1.5, height: viewSize.height / 1.5)
                    
                    Text("You can also show/hide some piano keys on the left hand side, as well as change the background style to better help you identify different intervals.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                case 5:
                    Image("Tutorial6")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20)))
                        .frame(width: viewSize.width / 1.5, height: viewSize.height / 1.5)
                    
                    Text("Each question times how long it takes for you to answer the question, as well as if you got it correct. The correct answer will be shown in green, and if you did not get the question correct your answer will be shown in red.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                case 6:
                    Image("Tutorial7")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20)))
                        .frame(width: viewSize.width / 1.5, height: viewSize.height / 1.5)
                    
                    Text("Before you start the test you can complete as many practice questions as you want which are all randomly generated.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                case 7:
                    Spacer()
                    Spacer()
                    
                    Text("The test questions were orginally a randomly generated set of questions, but are the same for each test.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                    
                    Text("If you have completed the tests before and have entered your Tester ID, the test will be a set of random questions.")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                    
                    Spacer()
                    
                    Text("Click the 'Start Test' button to begin, good luck!")
                        .equivalentFont(.title)
                        .fontWeight(.semibold)
                        .equivalentPadding()
                default:
                    Text("")
                }
                
                Spacer()
                
                HStack(spacing: spacing) {
                    Button {
                        withAnimation(.easeInOut) {
                            currentPage -= 1
                        }
                    } label: {
                        Image(systemName: "arrow.left")
                            .equivalentFont(.title)
                            .fontWeight(.semibold)
                            .frame(width: buttonWidth / 2 - spacing / 2, height: buttonHeight)
                            .background(Color.secondary)
                            .cornerRadius(cornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(currentPage == 0)
                    
                    Button {
                        withAnimation(.easeInOut) {
                            currentPage += 1
                        }
                    } label: {
                        Image(systemName: "arrow.right")
                            .equivalentFont(.title)
                            .fontWeight(.semibold)
                            .frame(width: buttonWidth / 2 - spacing / 2, height: buttonHeight)
                            .background(Color.secondary)
                            .cornerRadius(cornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(currentPage == 7)
                }
                
                Button {
                    withAnimation(.easeInOut) {
                        showPracticeAlert = true
                    }
                } label: {
                    Text("Start Test")
                        .equivalentFont(.title2)
                        .fontWeight(.semibold)
                        .frame(width: buttonWidth, height: buttonHeight * 1.5)
                        .background(Color.accentColor)
                        .cornerRadius(cornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(currentPage != 7)
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
        }
        .frame(width: viewSize.width, height: viewSize.height)
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
