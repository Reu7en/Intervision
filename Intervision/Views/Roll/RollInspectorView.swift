//
//  RollInspectorView.swift
//  Intervision
//
//  Created by Reuben on 27/02/2024.
//

import SwiftUI

struct RollInspectorView: View {
    
    @Binding var presentedView: HomeView.PresentedView
    @Binding var widthScale: CGFloat
    @Binding var intervalLinesType: RollViewModel.IntervalLinesType
    
    let partSegmentColors: [Color]
    let parts: [Part]?
    
    let spacing: CGFloat = 20
    
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
                withAnimation(.easeInOut(duration: 1.0)) {
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
            
            if let parts = parts {
                HStack {
                    Text("Part Colour Key:")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
             
                ForEach(0..<parts.count, id: \.self) { partIndex in
                    let segmentColor = partIndex > partSegmentColors.count - 1 ? Color.black : partSegmentColors[partIndex]
                    
                    HStack {
                        Text("\(parts[partIndex].name ?? "")")
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(segmentColor)
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
            
            Picker("", selection: $intervalLinesType) {
                ForEach(RollViewModel.IntervalLinesType.allCases, id: \.self) { type in
                    Text("\(type.rawValue.capitalized)").tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    RollInspectorView(presentedView: Binding.constant(.Roll), widthScale: Binding.constant(1), intervalLinesType: Binding.constant(.none), partSegmentColors: [], parts: [])
        .frame(width: 500)
}
