//
//  TestingRegistrationView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct TestingRegistrationView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var isSliding = false
    @State private var showTesterIdAlert = false
    @State private var showTutorialAlert = false
    @State private var showPracticeAlert = false
    
    @FocusState private var testerIdFieldFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Tester ID")
                    .font(.title)
                    .padding()
                
                HStack {
                    TextField("Tester ID", text: $testingViewModel.id, prompt: Text("Example: 12345678-abcd-4ef0-9876-0123456789ab"))
                        .focused($testerIdFieldFocused)
                    
                    Button {
                        testerIdFieldFocused = false
                        showTesterIdAlert = true
                    } label: {
                        Image(systemName: "questionmark")
                    }
                    .alert(isPresented: $showTesterIdAlert) {
                        Alert(
                            title: Text("Input Your Tester ID Here"),
                            message: Text("If this is your first time completing any tests, you should leave this field blank! A unique Tester ID will be generated for you automatically.\n\nIf you have completed any tests before, you can find your Tester ID within your results data.")
                        )
                    }
                }
                
                Text("Experience")
                    .font(.title)
                    .padding()
                
                HStack {
                    Text("Perfomer")
                    
                    Spacer()
                    
                    Picker("", selection: $testingViewModel.performerSkillLevel) {
                        ForEach(Tester.SkillLevel.allCases, id: \.self) { skillLevel in
                            Text(String(describing: skillLevel))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: geometry.size.width / 1.5)
                    .onChange(of: testingViewModel.performerSkillLevel) {
                        testerIdFieldFocused = false
                    }
                }
                
                HStack {
                    Text("Composer")
                    
                    Spacer()
                    
                    Picker("", selection: $testingViewModel.composerSkillLevel) {
                        ForEach(Tester.SkillLevel.allCases, id: \.self) { skillLevel in
                            Text(String(describing: skillLevel))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: geometry.size.width / 1.5)
                    .onChange(of: testingViewModel.composerSkillLevel) {
                        testerIdFieldFocused = false
                    }
                }
                
                HStack {
                    Text("Theorist")
                    
                    Spacer()
                    
                    Picker("", selection: $testingViewModel.theoristSkillLevel) {
                        ForEach(Tester.SkillLevel.allCases, id: \.self) { skillLevel in
                            Text(String(describing: skillLevel))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: geometry.size.width / 1.5)
                    .onChange(of: testingViewModel.theoristSkillLevel) {
                        testerIdFieldFocused = false
                    }
                }
                
                HStack {
                    Text("Music Educator")
                    
                    Spacer()
                    
                    Picker("", selection: $testingViewModel.educatorSkillLevel) {
                        ForEach(Tester.SkillLevel.allCases, id: \.self) { skillLevel in
                            Text(String(describing: skillLevel))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: geometry.size.width / 1.5)
                    .onChange(of: testingViewModel.educatorSkillLevel) {
                        testerIdFieldFocused = false
                    }
                }
                
                HStack {
                    Text("Software Developer")
                    
                    Spacer()
                    
                    Picker("", selection: $testingViewModel.developerSkillLevel) {
                        ForEach(Tester.SkillLevel.allCases, id: \.self) { skillLevel in
                            Text(String(describing: skillLevel))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: geometry.size.width / 1.5)
                    .onChange(of: testingViewModel.developerSkillLevel) {
                        testerIdFieldFocused = false
                    }
                }
                
                Text("Question Count - \(testingViewModel.questionCount)")
                    .font(.title)
                    .padding()
                
                Slider(
                    value: Binding(
                        get: { Double(testingViewModel.questionCount) },
                        set: { testingViewModel.questionCount = Int($0) }
                    ),
                    in: 30...150,
                    step: 30
                ) {
                    Text("")
                } minimumValueLabel: {
                    Text("\(30)")
                } maximumValueLabel: {
                    Text("\(150)")
                } onEditingChanged: { sliding in
                    isSliding = sliding
                }
                .onChange(of: testingViewModel.questionCount) {
                    testerIdFieldFocused = false
                }
                
                Spacer()
                
                Button {
                    testerIdFieldFocused = false
                    
                    withAnimation(.easeInOut) {
                        showTutorialAlert = true
                    }
                } label: {
                    Text("Start Tests")
                        .font(.title2)
                        .padding()
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
            .padding(.horizontal, geometry.size.width / 20)
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    testerIdFieldFocused = false
                }
            )
            .onExitCommand {
                testerIdFieldFocused = false
            }
        }
    }
}

#Preview {
    TestingRegistrationView(testingViewModel: TestingViewModel())
}
