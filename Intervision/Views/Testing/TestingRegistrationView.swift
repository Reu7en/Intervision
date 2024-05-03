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
        #if os(macOS)
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 2, height: screenSizeViewModel.screenSize.height / 2)
        #elseif os(iOS)
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 1.1, height: screenSizeViewModel.screenSize.height / 1.1)
        #endif
        
        #if os(macOS)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(40)
        #elseif os(iOS)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(80)
        #endif
        
        let spacing = screenSizeViewModel.getEquivalentValue(20)
        let questionMarkButtonWidth = viewSize.width / 10
        let textFieldWidth = viewSize.width - questionMarkButtonWidth - spacing
        let skillsButtonWidth = (viewSize.width / 4) - (spacing * 3 / 4)
        let rollRowsViewTypeButtonWidth = (viewSize.width / 5) - (spacing) - (questionMarkButtonWidth / 5)
        let cornerRadius = screenSizeViewModel.getEquivalentValue(8)
        
        ZStack {
            VStack(spacing: spacing / 2) {
                Text("Tester ID")
                    .equivalentFont(.title)
                    .equivalentPadding()
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    TextEditor(text: $testingViewModel.testerId)
                        .equivalentFont(.title3)
                        .equivalentPadding()
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
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundStyle(Color.clear)
                        .frame(width: questionMarkButtonWidth, height: buttonHeight)
                        .background(Color.secondary)
                        .cornerRadius(cornerRadius)
                        .overlay {
                            Image(systemName: "questionmark")
                                .equivalentFont(.title3)
                                .fontWeight(.semibold)
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showTesterIdAlert.toggle()
                            }
                        }
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
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(Color.clear)
                            .frame(width: skillsButtonWidth, height: buttonHeight)
                            .background(skillLevel == testingViewModel.performerSkillLevel ? Color.accentColor : Color.secondary)
                            .cornerRadius(cornerRadius)
                            .overlay {
                                Text(skillLevel.rawValue)
                                    .equivalentFont(.title3)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    testerIdFieldFocused = false
                                    testingViewModel.performerSkillLevel = skillLevel
                                }
                            }
                    }
                }
                
                Text("Composer")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(Color.clear)
                            .frame(width: skillsButtonWidth, height: buttonHeight)
                            .background(skillLevel == testingViewModel.composerSkillLevel ? Color.accentColor : Color.secondary)
                            .cornerRadius(cornerRadius)
                            .overlay {
                                Text(skillLevel.rawValue)
                                    .equivalentFont(.title3)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    testerIdFieldFocused = false
                                    testingViewModel.composerSkillLevel = skillLevel
                                }
                            }
                    }
                }
            
                Text("Theorist")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(Color.clear)
                            .frame(width: skillsButtonWidth, height: buttonHeight)
                            .background(skillLevel == testingViewModel.theoristSkillLevel ? Color.accentColor : Color.secondary)
                            .cornerRadius(cornerRadius)
                            .overlay {
                                Text(skillLevel.rawValue)
                                    .equivalentFont(.title3)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    testerIdFieldFocused = false
                                    testingViewModel.theoristSkillLevel = skillLevel
                                }
                            }
                    }
                }
                
                Text("Music Educator")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(Color.clear)
                            .frame(width: skillsButtonWidth, height: buttonHeight)
                            .background(skillLevel == testingViewModel.educatorSkillLevel ? Color.accentColor : Color.secondary)
                            .cornerRadius(cornerRadius)
                            .overlay {
                                Text(skillLevel.rawValue)
                                    .equivalentFont(.title3)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    testerIdFieldFocused = false
                                    testingViewModel.educatorSkillLevel = skillLevel
                                }
                            }
                    }
                }
                
                Text("Software Developer")
                    .equivalentFont(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(Color.clear)
                            .frame(width: skillsButtonWidth, height: buttonHeight)
                            .background(skillLevel == testingViewModel.developerSkillLevel ? Color.accentColor : Color.secondary)
                            .cornerRadius(cornerRadius)
                            .overlay {
                                Text(skillLevel.rawValue)
                                    .equivalentFont(.title3)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    testerIdFieldFocused = false
                                    testingViewModel.developerSkillLevel = skillLevel
                                }
                            }
                    }
                }
                
                Text("Piano Roll Background")
                    .equivalentFont(.title)
                    .equivalentPadding()
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    ForEach(BarRowsView.ViewType.allCases, id: \.self) { viewType in
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(Color.clear)
                            .frame(width: rollRowsViewTypeButtonWidth, height: buttonHeight)
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
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundStyle(Color.clear)
                        .frame(width: questionMarkButtonWidth, height: buttonHeight)
                        .background(Color.secondary)
                        .cornerRadius(cornerRadius)
                        .overlay {
                            Image(systemName: "questionmark")
                                .equivalentFont(.title3)
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                testerIdFieldFocused = false
                                showRollBackgroundOverlay.toggle()
                            }
                        }
                }
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut) {
                        testerIdFieldFocused = false
                        
                        if !testingViewModel.testerId.isEmpty {
                            if let _ = UUID(uuidString: testingViewModel.testerId) {
                                withAnimation(.easeInOut) {
                                    //                                showTutorialAlert = true
                                    testingViewModel.random = true
                                    showPracticeAlert = true
                                }
                            } else {
                                withAnimation(.easeInOut) {
                                    showInvalidIdAlert = true
                                }
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                //                            showTutorialAlert = true
                                showPracticeAlert = true
                            }
                        }
                    }
                } label: {
                    Text("Start Tests")
                        .equivalentFont(.title)
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
            .overlay {
                if showRollBackgroundOverlay {
                    VStack {
                        Text("You can change how the background of the piano roll looks to better help you identify different intervals")
                            .equivalentPadding(.top)
                            .equivalentFont(.title2)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Spacer()
                            
                            BarRowsView(
                                rows: 12,
                                rowWidth: viewSize.width * 0.9,
                                rowHeight: viewSize.height / 20,
                                beats: 1,
                                viewType: testingViewModel.rollRowsViewType,
                                image: false
                            )
                            .equivalentPadding(.top)
                            
                            Spacer()
                        }
                        
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
                        .equivalentPadding(.top)
                        .frame(width: viewSize.width * 0.9)
                        
                        Text("This can be changed at any time when answering questions")
                            .equivalentPadding(.top)
                            .equivalentFont(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: skillsButtonWidth, height: buttonHeight * 1.5)
                            .background(Color.secondary)
                            .cornerRadius(cornerRadius)
                            .equivalentPadding()
                            .overlay {
                                Text("OK")
                                    .equivalentFont(.title)
                                    .fontWeight(.bold)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    showRollBackgroundOverlay = false
                                }
                            }
                    }
                    .equivalentPadding(padding: 50)
                    .background(.ultraThickMaterial)
                    .cornerRadius(screenSizeViewModel.getEquivalentValue(20))
                    .cornerRadius(cornerRadius)
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    testerIdFieldFocused = false
                }
            )
            #if os(macOS)
            .onExitCommand {
                testerIdFieldFocused = false
            }
            #endif
        }
        .frame(width: viewSize.width, height: viewSize.height)
        .position(x: screenSizeViewModel.screenSize.width / 2, y: screenSizeViewModel.screenSize.height / 2)
        .environmentObject(screenSizeViewModel)
    }
}

#Preview {
    TestingRegistrationView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
        .frame(width: 1000, height: 1000)
}
