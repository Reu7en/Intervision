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
    @Binding var intervalLinesType: RollViewModel.IntervalLinesType
    
    let partSegmentColors: [Color]
    let parts: [Part]?
    let intervalLineColors: [Color]
    
    let spacing: CGFloat = 20
    let intervals: [String] = [
        "Minor 2nd",
        "Major 2nd",
        "Minor 3rd",
        "Major 3rd",
        "Perfect 4th",
        "Tritone",
        "Perfect 5th",
        "Minor 6th",
        "Major 6th",
        "Minor 7th",
        "Major 7th",
        "Octave"
    ]
    
    var body: some View {
        VStack(spacing: spacing) {  
            Spacer()
                .frame(height: spacing / 2)
            
            HStack {
                Text("View Type:")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Picker("", selection: $presentedView) {
                ForEach(HomeView.PresentedView.allCases.filter({ $0 != .None }), id: \.self) { type in
                    Text("\(type.rawValue.capitalized)").tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: presentedView) { newValue, _ in
                withAnimation(.easeInOut(duration: 0.75)) {
                    presentedView = newValue
                }
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

            if let score = rollViewModel.score,
               let parts = score.parts {
                ForEach(0..<parts.count, id: \.self) { partIndex in
                    let part = parts[partIndex]
                    let segmentColor: Color = {
                        if let parts = rollViewModel.parts,
                           let index = parts.firstIndex(of: part) {
                            if index < partSegmentColors.count {
                                return partSegmentColors[index]
                            } else {
                                return Color.black
                            }
                        } else {
                            return Color.clear
                        }
                    }()
                    
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
                                    } else {
                                        rollViewModel.removePart(part)
                                    }
                                }
                            )
                        )
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black)
                            .background (
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(segmentColor)
                            )
                            .frame(height: spacing)
                            .frame(maxWidth: spacing * 3)
                    }
                }
            }
            
            HStack {
                Text("Show Interval Lines:")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Picker("", selection: $intervalLinesType.animation(.easeInOut)) {
                ForEach(RollViewModel.IntervalLinesType.allCases, id: \.self) { type in
                    Text("\(type.rawValue.capitalized)").tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if intervalLinesType != .none {
                HStack {
                    Text("Interval Colour Key:")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                ForEach(0..<intervalLineColors.count, id: \.self) { colorIndex in
                    let intervalLineColor = intervalLineColors[colorIndex]
                    
                    HStack {
                        Text("\(intervals[colorIndex])")
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black)
                            .background (
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(intervalLineColor)
                            )
                            .frame(height: spacing)
                            .frame(maxWidth: spacing * 3)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            Color.black.opacity(0.25)
        )
    }
}

#Preview {
    RollInspectorView(rollViewModel: RollViewModel(score: Score()), presentedView: Binding.constant(.Roll), widthScale: Binding.constant(1), intervalLinesType: Binding.constant(.none), partSegmentColors: [], parts: [], intervalLineColors: [])
        .frame(width: 500)
}
