//
//  TestingRegistrationView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct TestingRegistrationView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var isSliding = false
    @State private var showTesterIdAlert = false
    @State private var showTutorialAlert = false
    @State private var showPracticeAlert = false
    @State private var showInvalidIdAlert = false
    @State private var showRollBackgroundOverlay = false
    @State private var overlayRollRowsViewType = BarRowsView.ViewType.Piano
    
    @FocusState private var testerIdFieldFocused: Bool
    
    var body: some View {
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 1.1, height: screenSizeViewModel.screenSize.height / 1.1)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(80)
        let spacing = screenSizeViewModel.getEquivalentValue(20)
        let questionMarkButtonWidth = viewSize.width / 10
        let textFieldWidth = viewSize.width - questionMarkButtonWidth - spacing
        let skillsButtonWidth = (viewSize.width / 4) - (spacing * 3 / 4)
        let rollRowsViewTypeButtonWidth = (viewSize.width / 5) - (spacing) - (questionMarkButtonWidth / 5)
        let cornerRadius = screenSizeViewModel.getEquivalentValue(8)
        
        ZStack {
            VStack(spacing: spacing) {
                Text("Tester ID")
                    .equivalentFont(.title)
                    .equivalentPadding()
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    TextEditor(text: $testingViewModel.testerId)
                        .equivalentFont(.title3)
                        .fontWeight(.semibold)
                        .frame(width: textFieldWidth, height: buttonHeight)
                        .lineLimit(1)
                        .scrollContentBackground(.hidden)
                        .scrollDisabled(true)
                        .background(Color.secondary)
                        .cornerRadius(cornerRadius)
                        .focused($testerIdFieldFocused)
                        .onTapGesture {
                            testerIdFieldFocused = true
                        }
                    
                    Button {
                        withAnimation(.easeInOut) {
                            showTesterIdAlert.toggle()
                        }
                    } label: {
                        Image(systemName: "questionmark")
                            .equivalentFont(.title2)
                            .fontWeight(.semibold)
                            .frame(width: questionMarkButtonWidth, height: buttonHeight)
                            .background(Color.accentColor)
                            .cornerRadius(cornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .alert(isPresented: $showTesterIdAlert) {
                        Alert(
                            title: Text("Input Your Tester ID Here"),
                            message: Text("If this is your first time completing the test, you should leave this field blank! A unique Tester ID will be generated for you automatically.\n\nIf you have completed the test before, you can find your Tester ID within your results data.")
                        )
                    }
                }
                
                Text("Experience")
                    .equivalentFont(.title)
                    .equivalentPadding()
                    .fontWeight(.semibold)
                
                Text("Perfomer")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        Button {
                            withAnimation(.easeInOut) {
                                testerIdFieldFocused = false
                                testingViewModel.performerSkillLevel = skillLevel
                            }
                        } label: {
                            Text(skillLevel.rawValue)
                                .equivalentFont(.title2)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.performerSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Text("Composer")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        Button {
                            withAnimation(.easeInOut) {
                                testerIdFieldFocused = false
                                testingViewModel.composerSkillLevel = skillLevel
                            }
                        } label: {
                            Text(skillLevel.rawValue)
                                .equivalentFont(.title2)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.composerSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            
                Text("Theorist")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        Button {
                            withAnimation(.easeInOut) {
                                testerIdFieldFocused = false
                                testingViewModel.theoristSkillLevel = skillLevel
                            }
                        } label: {
                            Text(skillLevel.rawValue)
                                .equivalentFont(.title2)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.theoristSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Text("Music Educator")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        Button {
                            withAnimation(.easeInOut) {
                                testerIdFieldFocused = false
                                testingViewModel.educatorSkillLevel = skillLevel
                            }
                        } label: {
                            Text(skillLevel.rawValue)
                                .equivalentFont(.title2)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.educatorSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Text("Software Developer")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        Button {
                            withAnimation(.easeInOut) {
                                testerIdFieldFocused = false
                                testingViewModel.developerSkillLevel = skillLevel
                            }
                        } label: {
                            Text(skillLevel.rawValue)
                                .equivalentFont(.title2)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.developerSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut) {
                        testerIdFieldFocused = false
                        
                        if !testingViewModel.testerId.isEmpty {
                            if let _ = UUID(uuidString: testingViewModel.testerId) {
                                //                                showTutorialAlert = true
                                testingViewModel.random = true
                                showPracticeAlert = true
                            } else {
                                showInvalidIdAlert = true
                            }
                        } else {
                            //                            showTutorialAlert = true
                            showPracticeAlert = true
                        }
                    }
                } label: {
                    Text("Start Tests")
                        .equivalentFont(.title)
                        .fontWeight(.semibold)
                        .frame(width: skillsButtonWidth, height: buttonHeight * 1.5)
                        .background(Color.secondary)
                        .cornerRadius(cornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
                .alert("Would you like to view the tutorial first?", isPresented: $showTutorialAlert) {
                    Button {
                        testingViewModel.tutorial = true
                    } label: {
                        Text("Yes")
                    }
                    
                    Button {
                        testingViewModel.tutorial = false
                        
                        withAnimation(.easeInOut) {
                            showPracticeAlert = true
                        }
                    } label: {
                        Text("No")
                    }
                }
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
                .alert(isPresented: $showInvalidIdAlert) {
                    Alert(
                        title: Text("Your Tester ID is invalid!")
                    )
                }
            }
            .overlay {
                if showRollBackgroundOverlay {
                    VStack(spacing: spacing / 2) {
                        Text("You can change how the background of the piano roll looks to better help you identify different intervals")
                            .equivalentFont(.title)
                            .equivalentPadding(.bottom)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                        
                        HStack(spacing: 0) {
                            let pianoKeysWidth = testingViewModel.showPiano ? viewSize.width / 6 : 0
                            let barRowsWidth = viewSize.width * 0.9 - pianoKeysWidth
                            
                            Spacer()
                            
                            PianoKeysView(
                                octaves: 1,
                                width: pianoKeysWidth, 
                                rowHeight: viewSize.height / 25,
                                showOctaveLabel: false,
                                fontSize: 0
                            )
                            .border(Color.black)
                            .transition(.move(edge: .leading))
                            
                            BarRowsView(
                                rows: 12,
                                rowWidth: barRowsWidth,
                                rowHeight: viewSize.height / 25,
                                beats: 1,
                                viewType: testingViewModel.rollRowsViewType,
                                image: false
                            )
                            .transition(.move(edge: .leading))
                            
                            Spacer()
                        }
                        .equivalentPadding(.bottom)
                        
                        HStack(spacing: spacing) {
                            ForEach(BarRowsView.ViewType.allCases, id: \.self) { viewType in
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(Color.clear)
                                    .frame(height: buttonHeight)
                                    .background(viewType == testingViewModel.rollRowsViewType ? Color.accentColor : Color.secondary)
                                    .cornerRadius(cornerRadius)
                                    .overlay {
                                        Text(viewType.rawValue)
                                            .equivalentFont(.title3)
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            testerIdFieldFocused = false
                                            testingViewModel.rollRowsViewType = viewType
                                        }
                                    }
                            }
                        }
                        .frame(width: viewSize.width * 0.9)
                        
                        Text("You can also show or hide the piano keys")
                            .equivalentPadding(.top)
                            .equivalentFont(.title)
                            .fontWeight(.semibold)
                        
                        Button {
                            withAnimation(.easeInOut) {
                                testingViewModel.showPiano.toggle()
                            }
                        } label: {
                            Image(systemName: "pianokeys.inverse")
                                .equivalentFont(.largeTitle)
                                .frame(width: buttonHeight * 2, height: buttonHeight)
                                .background(testingViewModel.showPiano ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Text("These can both be changed at any time during the test")
                            .equivalentPadding(.top)
                            .equivalentFont(.title)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut) {
                                showRollBackgroundOverlay = false
                            }
                        } label: {
                            Text("OK")
                                .equivalentFont(.title)
                                .frame(width: skillsButtonWidth, height: buttonHeight * 1.5)
                                .background(Color.accentColor)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .equivalentPadding(padding: 50)
                    .background(.ultraThickMaterial)
                    .cornerRadius(screenSizeViewModel.getEquivalentValue(20))
                    .cornerRadius(cornerRadius)
                }
            }
            #if os(macOS)
            .onExitCommand {
                testerIdFieldFocused = false
            }
            #endif
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
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                testerIdFieldFocused = false
            }
        )
        .environmentObject(screenSizeViewModel)
        #if os(macOS)
        .scaleEffect(0.5)
        #endif
    }
}

#Preview {
    TestingRegistrationView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
        .frame(width: 1000, height: 1000)
}
