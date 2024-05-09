//
//  TestingRegistrationView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct TestingRegistrationView: View {
    
    @EnvironmentObject var screenSizeViewModel: DynamicSizingViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @Binding var presentedHomeView: HomeView.PresentedView
    
    @State private var isSliding = false
    @State private var showTesterIdAlert = false
    @State private var showTutorialAlert = false
    @State private var showPracticeAlert = false
    @State private var showInvalidIdAlert = false
    @State private var showSaveFormsAlert = false
    
    @FocusState private var testerIdFieldFocused: Bool
    
    var body: some View {
        let viewSize = CGSize(width: screenSizeViewModel.viewSize.width / 1.1, height: screenSizeViewModel.viewSize.height / 1.1)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(80)
        let spacing = screenSizeViewModel.getEquivalentValue(20)
        let questionMarkButtonWidth = viewSize.width / 10
        let textFieldWidth = viewSize.width - questionMarkButtonWidth - spacing
        let skillsButtonWidth = (viewSize.width / 4) - (spacing * 3 / 4)
        let cornerRadius = screenSizeViewModel.getEquivalentValue(8)
        
        ZStack {
            VStack(spacing: spacing) {
                Text("Tester ID")
                    .dynamicFont(.title2)
                    .dynamicPadding()
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    TextEditor(text: $testingViewModel.testerId)
                        #if os(macOS)
                        .dynamicPadding(.top, 16)
                        .dynamicPadding(.leading, 4)
                        #endif
                        .dynamicFont(.title3)
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
                        .overlay {
                            if testingViewModel.testerId.isEmpty {
                                HStack {
                                    Text(" Example: 12345678-abcd-4ef0-9876-0123456789ab")
                                        .dynamicFont(.title3)
                                        .fontWeight(.semibold)
                                        .opacity(0.5)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .alert(isPresented: $showInvalidIdAlert) {
                            Alert(
                                title: Text("Your Tester ID is invalid!"),
                                message: Text("Your Tester ID should be in UUID format, for example: 12345678-abcd-4ef0-9876-0123456789ab")
                            )
                        }
                    
                    Button {
                        withAnimation(.easeInOut) {
                            testerIdFieldFocused = false
                            showTesterIdAlert.toggle()
                        }
                    } label: {
                        Image(systemName: "questionmark")
                            .dynamicFont(.title3)
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
                    .dynamicFont(.title2)
                    .dynamicPadding()
                    .fontWeight(.semibold)
                
                Text("Performance")
                    .dynamicFont()
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
                                .dynamicFont(.title3)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.performerSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Text("Composition")
                    .dynamicFont()
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
                                .dynamicFont(.title3)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.composerSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            
                Text("Theory")
                    .dynamicFont()
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
                                .dynamicFont(.title3)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.theoristSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Text("Music Education")
                    .dynamicFont()
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
                                .dynamicFont(.title3)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.educatorSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Text("Software Development")
                    .dynamicFont()
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
                                .dynamicFont(.title3)
                                .fontWeight(.semibold)
                                .frame(width: skillsButtonWidth, height: buttonHeight)
                                .background(skillLevel == testingViewModel.developerSkillLevel ? Color.accentColor : Color.secondary)
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Text("Forms")
                    .dynamicFont(.title2)
                    .dynamicPadding()
                    .fontWeight(.semibold)
                
                HStack(spacing: spacing) {
                    Button {
                        testerIdFieldFocused = false
                        
                        DispatchQueue.main.async {
                            testingViewModel.savePDF(named: "Participant_Information_Sheet")
                            
                            withAnimation(.easeInOut) {
                                testingViewModel.participantInformationSheetSaved = true
                            }
                        }
                    } label: {
                        Text("Participant Information")
                            .dynamicFont(.title3)
                            .fontWeight(.semibold)
                            .frame(width: skillsButtonWidth, height: buttonHeight)
                            .background(testingViewModel.participantInformationSheetSaved ? Color.green : Color.red)
                            .cornerRadius(cornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        testerIdFieldFocused = false
                        
                        DispatchQueue.main.async {
                            testingViewModel.savePDF(named: "Consent_Form")
                            
                            withAnimation(.easeInOut) {
                                testingViewModel.consentFormSaved = true
                            }
                        }
                    } label: {
                        Text("Consent Form")
                            .dynamicFont(.title3)
                            .fontWeight(.semibold)
                            .frame(width: skillsButtonWidth, height: buttonHeight)
                            .background(testingViewModel.consentFormSaved ? Color.green : Color.red)
                            .cornerRadius(cornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut) {
                        testerIdFieldFocused = false
                        
                        if !testingViewModel.testerId.isEmpty {
                            if let _ = UUID(uuidString: testingViewModel.testerId) {
                                testingViewModel.random = true
                                showPracticeAlert = true
                            } else {
                                showInvalidIdAlert = true
                            }
                        } else {
                            showTutorialAlert = true
                        }
                    }
                } label: {
                    Text("Start Test")
                        .dynamicFont(.title2)
                        .fontWeight(.semibold)
                        .frame(width: skillsButtonWidth, height: buttonHeight * 1.5)
                        .background(Color.accentColor)
                        .cornerRadius(cornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!(testingViewModel.participantInformationSheetSaved && testingViewModel.consentFormSaved))
                .onTapGesture {
                    if !(testingViewModel.participantInformationSheetSaved && testingViewModel.consentFormSaved) {
                        showSaveFormsAlert = true
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
                .alert(isPresented: $showSaveFormsAlert) {
                    Alert(
                        title: Text("You need to save a copy of the participant information sheet and consent form before you can begin the test!")
                    )
                }
            }
            .overlay(alignment: .topLeading) {
                Button {
                    withAnimation(.easeInOut) {
                        presentedHomeView = .None
                    }
                } label: {
                    Image(systemName: "xmark")
                        .dynamicFont()
                        .dynamicPadding()
                }
            }
            #if os(macOS)
            .onExitCommand {
                testerIdFieldFocused = false
            }
            #endif
        }
        .frame(width: viewSize.width, height: viewSize.height)
        .dynamicPadding(50)
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
        .onTapGesture {
            testerIdFieldFocused = false
        }
        .environmentObject(screenSizeViewModel)
        #if os(macOS)
        .scaleEffect(0.75)
        #endif
        #if os(iOS)
        .sheet(item: $testingViewModel.pdfURL) { identifiableURL in
            ActivityView(activityItems: [identifiableURL.url])
        }
        #endif
    }
}

#Preview {
    TestingRegistrationView(testingViewModel: TestingViewModel(), presentedHomeView: Binding.constant(.None))
        .environmentObject(DynamicSizingViewModel())
        .frame(width: 1000, height: 1000)
}
