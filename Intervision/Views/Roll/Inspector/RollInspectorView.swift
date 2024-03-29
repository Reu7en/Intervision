//
//  RollInspectorView.swift
//  Intervision
//
//  Created by Reuben on 27/02/2024.
//

import SwiftUI

struct RollInspectorView: View {
    
    @StateObject var rollViewModel: RollViewModel
    
    @Binding var presentedView: HomeView.PresentedView
    @Binding var widthScale: CGFloat
    @Binding var heightScale: CGFloat
    @Binding var showDynamics: Bool
    
    let parts: [Part]?
    
    let spacing: CGFloat = 20
    let sectionBackgroundColor = Color.gray.opacity(0.25)
    
    @State private var isEditingGroupTitle = false
    @State private var initialGroupTitle: String?
    @State private var editedGroupName = ""
    @State private var showAddGroupTextField = false
    @State private var newGroupName = ""
    @FocusState private var isFocused: Bool
    @FocusState private var addFieldIsFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: spacing) {
                Spacer()
                    .frame(height: spacing / 2)
                
                VStack(alignment: .leading, spacing: spacing) {
                    HStack {
                        Text("View Type")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Picker("", selection: $presentedView) {
                            ForEach(HomeView.PresentedView.allCases.filter({ $0 != .None }), id: \.self) { type in
                                Text("\(type.rawValue.capitalized)").tag(type)
                            }
                        }
                        .pickerStyle(RadioGroupPickerStyle())
                        .onChange(of: presentedView) { newValue, _ in
                            withAnimation(.easeInOut(duration: 0.75)) {
                                presentedView = newValue
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(sectionBackgroundColor)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: spacing) {
                    HStack {
                        Text("Scale")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Stepper("Width:  " + (String(format: "%.3f", widthScale)), value: $widthScale, in: 0.125...2.0, step: 0.125)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Stepper("Height: " + (String(format: "%.3f", heightScale)), value: $heightScale, in: 0.5...2.0, step: 0.25)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Toggle(
                            "Show Dynamics",
                            isOn: Binding<Bool>(
                                get: {
                                    return showDynamics
                                },
                                set: { newValue in
                                    withAnimation(.easeInOut) {
                                        showDynamics = newValue
                                    }
                                }
                            )
                        )
                        .font(.title2)
                        .fontWeight(.bold)
                        .toggleStyle(RightSwitchToggleStyle())
                        
                        Spacer()
                    }
                }
                .padding()
                .background(sectionBackgroundColor)
                .cornerRadius(8)
                
                VStack(spacing: spacing) {
                    ForEach(rollViewModel.partGroups, id: \.0) { groupTitle, groupParts in
                        HStack {
                            if isEditingGroupTitle && initialGroupTitle == groupTitle {
                                TextField("Group Name", text: $editedGroupName)
                                    .font(.title2)
                                    .focused($isFocused)
                                    .onExitCommand {
                                        isEditingGroupTitle = false
                                        editedGroupName = ""
                                        initialGroupTitle = nil
                                    }
                                    .onSubmit {
                                        isEditingGroupTitle = false
                                        
                                        if !editedGroupName.isEmpty {
                                            withAnimation(.easeInOut) {
                                                rollViewModel.renamePartGroup(from: groupTitle, to: editedGroupName)
                                            }
                                        }
                                        
                                        editedGroupName = ""
                                        initialGroupTitle = nil
                                    }
                            } else {
                                HStack {
                                    Text(groupTitle)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .onTapGesture(count: 2) {
                                            withAnimation(.easeInOut) {
                                                isEditingGroupTitle = true
                                                isFocused = true
                                                editedGroupName = groupTitle
                                                initialGroupTitle = groupTitle
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        ForEach(groupParts, id: \.id) { part in
                            if let score = rollViewModel.scoreManager.score,
                               let partIndex = score.parts?.firstIndex(of: part) {
                                let partColor = RollViewModel.melodicIntervalLineColors[partIndex]
                                
                                HStack {
                                    Toggle(
                                        "\(part.name ?? "Part \(partIndex)")",
                                        isOn: Binding<Bool>(
                                            get: {
                                                if let selectedParts = rollViewModel.parts {
                                                    return selectedParts.contains(part)
                                                } else {
                                                    return false
                                                }
                                            },
                                            set: { newValue in
                                                withAnimation(.easeInOut) {
                                                    if newValue {
                                                        rollViewModel.addPart(part)
                                                        rollViewModel.viewablePartSegmentColors[partIndex] = partColor
                                                        rollViewModel.addViewableMelodicLine(partIndex)
                                                    } else {
                                                        rollViewModel.removePart(part)
                                                        rollViewModel.viewablePartSegmentColors[partIndex] = Color.clear
                                                        rollViewModel.removeViewableMelodicLine(partIndex)
                                                    }
                                                }
                                            }
                                        )
                                    )
                                    
                                    Spacer()
                                    
                                    ColorPicker("", selection: Binding<Color>(
                                        get: {
                                            return rollViewModel.viewablePartSegmentColors[partIndex]
                                        },
                                        set: { newValue in
                                            withAnimation(.easeInOut) {
                                                rollViewModel.viewablePartSegmentColors[partIndex] = newValue
                                            }
                                        }
                                    ))
                                    .frame(height: spacing)
                                    .frame(width: spacing * 2)
                                }
                                
                                if rollViewModel.partGroups.count > 1 {
                                    Picker("", selection: Binding<String>(
                                        get: {
                                            return rollViewModel.partGroups.first(where: { $0.1.contains(part) })?.0 ?? ""
                                        },
                                        set: { newGroup in
                                            if let currentGroup = rollViewModel.partGroups.firstIndex(where: { $0.1.contains(part) }) {
                                                withAnimation(.easeInOut) {
                                                    rollViewModel.movePart(part, from: rollViewModel.partGroups[currentGroup].0, to: newGroup)
                                                }
                                            }
                                        }
                                    )) {
                                        ForEach(rollViewModel.partGroups.map { $0.0 }, id: \.self) { groupName in
                                            Text(groupName)
                                                .tag(groupName)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }
                        }
                    }
                    
                    HStack(alignment: .center) {
                        if showAddGroupTextField {
                            TextField("New Group Name", text: $newGroupName)
                                .font(.title2)
                                .focused($addFieldIsFocused)
                                .onExitCommand {
                                    showAddGroupTextField = false
                                    newGroupName = ""
                                }
                                .onSubmit {
                                    showAddGroupTextField = false
                                    
                                    if !newGroupName.isEmpty {
                                        withAnimation(.easeInOut) {
                                            rollViewModel.createPartGroup(groupName: newGroupName)
                                            newGroupName = ""
                                        }
                                    }
                                }
                        } else {
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    addFieldIsFocused = true
                                    showAddGroupTextField.toggle()
                                }
                            }) {
                                Text("Add New Group")
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(height: spacing * 3)
                }
                .padding()
                .background(sectionBackgroundColor)
                .cornerRadius(8)
                
                if rollViewModel.harmonicIntervalLinesType != .none || rollViewModel.showMelodicIntervalLines {
                    VStack(alignment: .leading, spacing: spacing) {
                        HStack {
                            Toggle(
                                "Show Inverted Intervals",
                                isOn: Binding<Bool>(
                                    get: {
                                        return rollViewModel.showInvertedIntervals
                                    },
                                    set: { newValue in
                                        withAnimation(.easeInOut) {
                                            if newValue {
                                                rollViewModel.showInvertedIntervals = newValue
                                                rollViewModel.viewableIntervals = RollViewModel.invertedIntervals
                                                rollViewModel.viewableHarmonicIntervalLineColors = RollViewModel.invertedHarmonicIntervalLineColors
                                                rollViewModel.viewableMelodicIntervalLineColors = RollViewModel.invertedMelodicIntervalLineColors
                                            } else {
                                                rollViewModel.showInvertedIntervals = newValue
                                                rollViewModel.viewableIntervals = RollViewModel.intervals
                                                rollViewModel.viewableHarmonicIntervalLineColors = RollViewModel.harmonicIntervalLineColors
                                                rollViewModel.viewableMelodicIntervalLineColors = RollViewModel.melodicIntervalLineColors
                                            }
                                        }
                                    }
                                )
                            )
                            .font(.title2)
                            .fontWeight(.bold)
                            .toggleStyle(RightSwitchToggleStyle())
                            
                            Spacer()
                        }
                        
                        if rollViewModel.showInvertedIntervals {
                            HStack {
                                Toggle("Show Zig-Zags Lines", isOn: $rollViewModel.showZigZags.animation(.easeInOut))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .toggleStyle(RightSwitchToggleStyle())
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(sectionBackgroundColor)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: spacing) {
                    HStack {
                        Text("Show Harmonic Intervals")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Picker("", selection: $rollViewModel.harmonicIntervalLinesType.animation(.easeInOut)) {
                            ForEach(IntervalLinesViewModel.IntervalLinesType.allCases, id: \.self) { type in
                                Text("\(type.rawValue.capitalized)").tag(type)
                            }
                        }
                        .pickerStyle(RadioGroupPickerStyle())
                        
                        Spacer()
                    }
                    
                    if rollViewModel.harmonicIntervalLinesType != .none {
                        HStack {
                            Text("Harmonic Lines Key")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        ForEach(0..<rollViewModel.viewableIntervals.count, id: \.self) { colorIndex in
                            let intervalLineColor = RollViewModel.harmonicIntervalLineColors[colorIndex]
                            
                            HStack {
                                Toggle(
                                    "\(rollViewModel.viewableIntervals[colorIndex])",
                                    isOn: Binding<Bool>(
                                        get: {
                                            return rollViewModel.viewableHarmonicIntervalLineColors[colorIndex] != Color.clear
                                        },
                                        set: { newValue in
                                            withAnimation(.easeInOut) {
                                                if newValue {
                                                    rollViewModel.viewableHarmonicIntervalLineColors[colorIndex] = intervalLineColor
                                                } else {
                                                    rollViewModel.viewableHarmonicIntervalLineColors[colorIndex] = Color.clear
                                                }
                                            }
                                        }
                                    )
                                )
                                
                                Spacer()
                                
                                ColorPicker("", selection: $rollViewModel.viewableHarmonicIntervalLineColors[colorIndex])
                                    .frame(height: spacing)
                                    .frame(width: spacing * 2)
                            }
                        }
                    }
                }
                .padding()
                .background(sectionBackgroundColor)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: spacing) {
                    HStack {
                        Toggle(
                            "Show Melodic Intervals",
                            isOn: Binding<Bool>(
                                get: {
                                    return rollViewModel.showMelodicIntervalLines
                                },
                                set: { newValue in
                                    withAnimation(.easeInOut) {
                                        rollViewModel.showMelodicIntervalLines = newValue
                                        
                                        if newValue && rollViewModel.viewableMelodicLines.isEmpty {
                                            rollViewModel.addAllViewableMelodicLines()
                                        }
                                    }
                                }
                            )
                        )
                        .font(.title2)
                        .fontWeight(.bold)
                        .toggleStyle(RightSwitchToggleStyle())
                        
                        Spacer()
                    }
                
                    if rollViewModel.showMelodicIntervalLines {
                        if let score = rollViewModel.scoreManager.score,
                           let scoreParts = score.parts,
                           let parts = parts {
                            ForEach(0..<scoreParts.count, id:\.self) { scorePartIndex in
                                Toggle(
                                    "\(scoreParts[scorePartIndex].name ?? "Part \(scorePartIndex)")",
                                    isOn: Binding<Bool>(
                                        get: {
                                            return rollViewModel.viewableMelodicLines.contains(scorePartIndex)
                                        },
                                        set: { newValue in
                                            withAnimation(.easeInOut) {
                                                if newValue {
                                                    rollViewModel.addViewableMelodicLine(scorePartIndex)
                                                } else {
                                                    rollViewModel.removeViewableMelodicLine(scorePartIndex)
                                                    
                                                    if rollViewModel.viewableMelodicLines.isEmpty {
                                                        rollViewModel.showMelodicIntervalLines = false
                                                    }
                                                }
                                            }
                                        }
                                    )
                                )
                                .disabled(!parts.contains(scoreParts[scorePartIndex]))
                            }
                        }
                        
                        HStack {
                            Text("Melodic Lines Key")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        ForEach(0..<rollViewModel.viewableIntervals.count, id: \.self) { colorIndex in
                            let intervalLineColor = RollViewModel.melodicIntervalLineColors[colorIndex]
                            
                            HStack {
                                Toggle(
                                    "\(rollViewModel.viewableIntervals[colorIndex])",
                                    isOn: Binding<Bool>(
                                        get: {
                                            return rollViewModel.viewableMelodicIntervalLineColors[colorIndex] != Color.clear
                                        },
                                        set: { newValue in
                                            withAnimation(.easeInOut) {
                                                if newValue {
                                                    rollViewModel.viewableMelodicIntervalLineColors[colorIndex] = intervalLineColor
                                                } else {
                                                    rollViewModel.viewableMelodicIntervalLineColors[colorIndex] = Color.clear
                                                }
                                            }
                                        }
                                    )
                                )
                                
                                Spacer()
                                
                                ColorPicker("", selection: $rollViewModel.viewableMelodicIntervalLineColors[colorIndex])
                                    .frame(height: spacing)
                                    .frame(width: spacing * 2)
                            }
                        }
                    }
                }
                .padding()
                .background(sectionBackgroundColor)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
        .background(
            Material.ultraThin
        )
        .clipShape(
            UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8, bottomTrailingRadius: 0, topTrailingRadius: 0)
        )
        .scrollIndicators(.never)
    }
}

struct RightSwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Toggle("", isOn: configuration.$isOn)
                .labelsHidden()
        }
    }
}

#Preview {
    RollInspectorView(rollViewModel: RollViewModel(scoreManager: ScoreManager()), presentedView: Binding.constant(.Roll), widthScale: Binding.constant(1), heightScale: Binding.constant(1), showDynamics: Binding.constant(true), parts: [])
        .frame(width: 500)
}
