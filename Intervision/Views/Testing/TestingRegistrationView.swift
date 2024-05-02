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
    @State private var showInvalidIdAlert = false
    @State private var showRollBackgroundOverlay = false
    @State private var overlayRollRowsViewType = BarRowsView.ViewType.Piano
    
    @FocusState private var testerIdFieldFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Tester ID")
                    .font(.title)
                    .padding()
                
                HStack {
                    TextField("Tester ID", text: $testingViewModel.testerId, prompt: Text("Example: 12345678-abcd-4ef0-9876-0123456789ab"))
                        .focused($testerIdFieldFocused)
                    
                    Spacer()
                    
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
                        ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
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
                        ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
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
                        ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
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
                        ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
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
                        ForEach(Skill.SkillLevel.allCases, id: \.self) { skillLevel in
                            Text(String(describing: skillLevel))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: geometry.size.width / 1.5)
                    .onChange(of: testingViewModel.developerSkillLevel) {
                        testerIdFieldFocused = false
                    }
                }
                
                Text("Piano Roll Background")
                    .font(.title)
                    .padding()
                
                HStack {
                    Spacer()
                    
                    Picker("", selection: $testingViewModel.rollRowsViewType) {
                        ForEach(BarRowsView.ViewType.allCases, id: \.self) { viewType in
                            Text(viewType.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: geometry.size.width / 1.5)
                    .onChange(of: testingViewModel.rollRowsViewType) {
                        testerIdFieldFocused = false
                    }
                
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button {
                        testerIdFieldFocused = false
                        
                        withAnimation(.easeInOut) {
                            showRollBackgroundOverlay = true
                        }
                    } label: {
                        Image(systemName: "questionmark")
                    }
                }
                
                Spacer()
                
                Button {
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
            .overlay {
                if showRollBackgroundOverlay {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack {
                        Text("You can change how the background of the piano roll looks to better help you identify different intervals")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        BarRowsView(
                            rows: 12,
                            rowWidth: geometry.size.width / 1.5,
                            rowHeight: geometry.size.height / 50,
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
                    .frame(width: geometry.size.width / 1.5)
                    .padding()
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
                }
            }
        }
    }
}

#Preview {
    TestingRegistrationView(testingViewModel: TestingViewModel())
        .frame(width: 1000, height: 1000)
}
