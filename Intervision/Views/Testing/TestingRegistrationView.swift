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
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 3, height: screenSizeViewModel.screenSize.height / 3)
        #elseif os(iOS)
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 1.1, height: screenSizeViewModel.screenSize.height / 1.1)
        #endif
        
        #if os(macOS)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(50)
        #elseif os(iOS)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(75)
        #endif
        
        let spacing = screenSizeViewModel.getEquivalentValue(20)
        let questionMarkButtonWidth = viewSize.width / 10
        let textFieldWidth = viewSize.width - questionMarkButtonWidth - spacing
        let skillsButtonWidth = (viewSize.width / 4) - (spacing * 3 / 4)
        let rollRowsViewTypeButtonWidth = (viewSize.width / 5) - (spacing) - (questionMarkButtonWidth / 5)
        let cornerRadius = screenSizeViewModel.getEquivalentValue(8)
        
        ZStack {
            VStack(spacing: spacing) {
                Text("Tester ID")
                    .equivalentFont(.largeTitle)
                    .equivalentPadding()
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    TextEditor(text: $testingViewModel.testerId)
                        .equivalentFont(.title3)
                        .equivalentPadding(.top, padding: 12)
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
                                showTesterIdAlert = true
                            }
                        }
                        .alert(isPresented: $showTesterIdAlert) {
                            Alert(
                                title: Text("Input Your Tester ID Here"),
                                message: Text("If this is your first time completing any tests, you should leave this field blank! A unique Tester ID will be generated for you automatically.\n\nIf you have completed any tests before, you can find your Tester ID within your results data.")
                            )
                        }
                }
                
                Text("Experience")
                    .equivalentFont(.largeTitle)
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
                                    .fontWeight(.semibold)
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
                                    .fontWeight(.semibold)
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
                                    .fontWeight(.semibold)
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
                                    .fontWeight(.semibold)
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
                                    .fontWeight(.semibold)
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
                    .equivalentFont(.largeTitle)
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
                                    .fontWeight(.semibold)
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
                                showRollBackgroundOverlay = true
                            }
                        }
                }
                
                Spacer()
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(Color.clear)
                    .frame(width: skillsButtonWidth, height: buttonHeight * 1.5)
                    .background(Color.secondary)
                    .cornerRadius(cornerRadius)
                    .equivalentPadding()
                    .overlay {
                        Text("Start Tests")
                            .equivalentFont(.title)
                            .fontWeight(.semibold)
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            testerIdFieldFocused = false
                            
                            if !testingViewModel.testerId.isEmpty {
                                if let _ = UUID(uuidString: testingViewModel.testerId) {
                                    withAnimation(.easeInOut) {
                                        //                                showTutorialAlert = true
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
                    }
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
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.ultraThickMaterial)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                    }
                    .shadow(radius: 10)
            )
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
            .overlay {
                if showRollBackgroundOverlay {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .clipShape(RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20)))
                    
                    VStack {
                        Text("You can change how the background of the piano roll looks to better help you identify different intervals")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        BarRowsView(
                            rows: 12,
                            rowWidth: screenSizeViewModel.screenSize.width,
                            rowHeight: screenSizeViewModel.screenSize.height / 50,
                            beats: 1,
                            viewType: testingViewModel.rollRowsViewType,
                            image: false
                        )
                        .padding()
                        
                        Picker("", selection: $testingViewModel.rollRowsViewType.animation(.easeInOut)) {
                            ForEach(BarRowsView.ViewType.allCases, id: \.self) { viewType in
                                Text(viewType.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        Text("This can be changed at any time when answering questions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        Button {
                            withAnimation(.easeInOut) {
                                showRollBackgroundOverlay = false
                            }
                        } label: {
                            Text("OK")
                                .foregroundColor(Color.white)
                                .padding()
                                .padding(.horizontal)
                        }
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding()
                    }
                }
            }
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
