//
//  RollView.swift
//  Intervision
//
//  Created by Reuben on 23/02/2024.
//

import SwiftUI

struct RollView: View {
    
    @Binding var presentedView: HomeView.PresentedView
    
    @StateObject var rollViewModel: RollViewModel
    
    @State var widthScale: CGFloat = 1.0
    @State var showInspector: Bool = false
    @State var intervalLinesType: RollViewModel.IntervalLinesType = .none
    
    let octaves = 9
    let partSegmentColors: [Color] = [
        .red,
        .yellow,
        .green,
        .blue,
        .purple
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let pianoKeysWidth = geometry.size.width / 10
            let barWidth = geometry.size.width / 3 * widthScale
            let rows = octaves * 12
            let rowHeight = geometry.size.height / CGFloat(rows / 2)
            
            HStack(spacing: 0) {
                ScrollView([.vertical, .horizontal]) {
                    LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        Section {
                            if let parts = rollViewModel.parts {
                                if parts.count > 0 {
                                    ForEach(0..<parts[0].bars.count, id: \.self) { barIndex in
                                        let (beats, noteValue) = RollViewModel.getBeatData(bar: parts[0].bars[barIndex][0])
                                        let rowWidth = CGFloat(beats) / CGFloat(noteValue) * barWidth
                                        
                                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                            Section {
                                                ZStack {
                                                    LazyVStack(spacing: 0) {
                                                        ForEach(0..<rows, id: \.self) { rowIndex in
                                                            ZStack {
                                                                Rectangle()
                                                                    .fill([1, 3, 5, 8, 10].contains(rowIndex % 12) ? Color.black.opacity(0.5) : Color.black.opacity(0.125))
                                                                    .frame(height: rowHeight)
                                                                    .border(Color.black.opacity(0.25))
                                                                
                                                                ForEach(0..<beats, id: \.self) { beatIndex in
                                                                    Path { path in
                                                                        let xPosition = CGFloat(beatIndex) * (rowWidth / CGFloat(beats))
                                                                        
                                                                        path.move(to: CGPoint(x: xPosition, y: 0))
                                                                        path.addLine(to: CGPoint(x: xPosition, y: rowHeight))
                                                                    }
                                                                    .stroke(Color.black.opacity(beatIndex == 0 ? 1.0 : 0.25))
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    ForEach(0..<parts.count, id: \.self) { partIndex in
                                                        RollBarView(
                                                            rollBarViewModel: RollBarViewModel(
                                                                bars: parts[partIndex].bars[barIndex],
                                                                octaves: octaves
                                                            ),
                                                            geometry: geometry,
                                                            barWidth: barWidth,
                                                            pianoKeysWidth: pianoKeysWidth,
                                                            rows: rows,
                                                            rowHeight: rowHeight,
                                                            partIndex: partIndex,
                                                            partSegmentColors: partSegmentColors
                                                        )
                                                    }
                                                }
                                            } header: {
                                                Rectangle()
                                                    .fill(Color.clear)
                                                    .frame(height: 30)
                                                    .overlay {
                                                        HStack(spacing: 0) {
                                                            Text("\(barIndex + 1)")
                                                                .foregroundStyle(Color.gray)
                                                                .padding(.horizontal, geometry.size.width / 200)
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                            }
                                        }
                                        .frame(width: rowWidth)
                                    }
                                } else {
                                    Color.clear
                                        .frame(width: geometry.size.width)
                                }
                            } else {
                                Color.clear
                                    .frame(width: geometry.size.width)
                            }
                        } header: {
                            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                Section {
                                    PianoKeysView(geometry: geometry, octaves: octaves, width: pianoKeysWidth, rowHeight: rowHeight)
                                } header: {
                                    Spacer()
                                        .frame(height: 30)
                                }
                            }
                            .frame(width: pianoKeysWidth)
                        }
                    }
                }
                
                if showInspector {
                    RollInspectorView(presentedView: $presentedView, widthScale: $widthScale, intervalLinesType: $intervalLinesType, partSegmentColors: partSegmentColors, parts: rollViewModel.parts)
                        .frame(width: geometry.size.width / 10)
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    withAnimation(.easeInOut) {
                        showInspector.toggle()
                    }
                } label: {
                    Image(systemName: "gear.circle")
                        .frame(width: 40, height: 20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(showInspector ? Color.accentColor : Color.clear)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.trailing)
                .padding(.top, 5)
            }
        }
    }
}

#Preview {
    RollView(presentedView: Binding.constant(.Roll), rollViewModel: RollViewModel(score: Score()))
}
