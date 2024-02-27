//
//  RollInspectorView.swift
//  Intervision
//
//  Created by Reuben on 27/02/2024.
//

import SwiftUI

struct RollInspectorView: View {
    
    @Binding var widthScale: CGFloat
    @Binding var intervalLinesType: RollViewModel.IntervalLinesType
    
    let partSegmentColors: [Color]
    let parts: [Part]?
    let rowHeight: CGFloat
    
    var body: some View {
        VStack(spacing: rowHeight / 2) {
            Spacer()
                .frame(height: 30)
            
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
                        
                        Rectangle()
                            .fill(segmentColor)
                            .frame(height: rowHeight)
                            .frame(maxWidth: rowHeight * 3)
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
    RollInspectorView(widthScale: Binding.constant(1), intervalLinesType: Binding.constant(.none), partSegmentColors: [], parts: [], rowHeight: 10)
        .frame(width: 500)
}
