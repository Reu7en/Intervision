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
    
    let parts: [Part]?
    
    let spacing: CGFloat = 20
    
    var body: some View {
        ScrollView {
            VStack(spacing: spacing) {
                Spacer()
                    .frame(height: spacing / 2)
                
                HStack {
                    Text("View Type:")
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
                
                HStack {
                    Text("Scale:")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                HStack {
                    Stepper("Width: \(widthScale.formatted())", value: $widthScale, in: 0.5...2.0, step: 0.5)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Parts:")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                if let score = rollViewModel.scoreManager.score,
                   let parts = score.parts {
                    ForEach(0..<parts.count, id: \.self) { partIndex in
                        let part = parts[partIndex]
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
                                        if newValue {
                                            rollViewModel.addPart(part)
                                            rollViewModel.viewablePartSegmentColors[partIndex] = partColor
                                        } else {
                                            rollViewModel.removePart(part)
                                            rollViewModel.viewablePartSegmentColors[partIndex] = Color.clear
                                        }
                                    }
                                )
                                .animation(.easeInOut)
                            )
                            
                            Spacer()
                            
                            ColorPicker("", selection: Binding<Color>(
                                get: {
                                    return rollViewModel.viewablePartSegmentColors[partIndex]
                                },
                                set: { newValue in
                                    withAnimation {
                                        rollViewModel.viewablePartSegmentColors[partIndex] = newValue
                                    }
                                }
                            ))
                            .frame(height: spacing)
                            .frame(width: spacing * 2)
                        }
                    }
                }
                
                if rollViewModel.harmonicIntervalLinesType != .none || rollViewModel.showMelodicIntervalLines {
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
                        
                        Spacer()
                    }
                    
                    if rollViewModel.showInvertedIntervals {
                        HStack {
                            Toggle("Show Zig-Zags", isOn: $rollViewModel.showZigZags.animation(.easeInOut))
                            
                            Spacer()
                        }
                    }
                }
                
                HStack {
                    Text("Show Harmonic Intervals:")
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
                        Text("Harmonic Lines Key:")
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

                HStack {
                    Toggle("Show Melodic Intervals", isOn: $rollViewModel.showMelodicIntervalLines.animation(.easeInOut))
                    
                    Spacer()
                }
                
                if rollViewModel.showMelodicIntervalLines {
                    HStack {
                        Text("Melodic Lines Key:")
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

#Preview {
    RollInspectorView(rollViewModel: RollViewModel(scoreManager: ScoreManager()), presentedView: Binding.constant(.Roll), widthScale: Binding.constant(1), parts: [])
        .frame(width: 500)
}
