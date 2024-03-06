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
    
    let octaves: Int
    
    var body: some View {
        GeometryReader { geometry in
            let rows = octaves * 12
            let pianoKeysWidth = geometry.size.width / 10
            let barWidth = geometry.size.width / 3 * widthScale
            let rowHeight = geometry.size.height / CGFloat(rows / 2)
            let headerHeight = geometry.size.height / 30
            let inspectorWidth = geometry.size.width / 8
            
            HStack(spacing: 0) {
                ScrollView([.vertical, .horizontal]) {
                    LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        Section {
                            if let parts = rollViewModel.parts, parts.indices.contains(0),
                               let segments = rollViewModel.segments {
                                ForEach(0..<parts[0].bars.count, id: \.self) { barIndex in
                                    if let bar = parts[0].bars[barIndex].first {
                                        let (beats, noteValue) = RollViewModel.getBeatData(bar: bar)
                                        let rowWidth = CGFloat(beats) / CGFloat(noteValue) * barWidth
                                        
                                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                            Section {
                                                ZStack {
                                                    BarRowsView(
                                                        rows: rows,
                                                        rowWidth: rowWidth,
                                                        rowHeight: rowHeight,
                                                        beats: beats
                                                    )
                                                    
                                                    IntervalLinesView(
                                                        intervalLinesViewModel: IntervalLinesViewModel(
                                                            segments: segments,
                                                            harmonicIntervalLinesType: rollViewModel.harmonicIntervalLinesType,
                                                            showMelodicIntervalLines: rollViewModel.showMelodicIntervalLines,
                                                            barIndex: barIndex,
                                                            barWidth: barWidth,
                                                            rowHeight: rowHeight
                                                        )
                                                    )
                                                    .id(UUID())
                                                    
                                                    RollBarView(
                                                        segments: segments,
                                                        barIndex: barIndex,
                                                        barWidth: barWidth,
                                                        rowHeight: rowHeight,
                                                        colors: rollViewModel.getSegmentColors()
                                                    )
                                                    .id(UUID())
                                                }
                                            } header: {
                                                RollBarHeader(
                                                    barIndex: barIndex,
                                                    headerHeight: headerHeight,
                                                    geometry: geometry
                                                )
                                            }
                                        }
                                        .frame(width: rowWidth)
                                    }
                                }
                            } else {
                                EmptyRollView(geometry: geometry)
                            }
                        } header: {
                            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                Section {
                                    PianoKeysView(
                                        geometry: geometry,
                                        octaves: octaves,
                                        width: pianoKeysWidth,
                                        rowHeight: rowHeight
                                    )
                                } header: {
                                    PianoKeysHeader(
                                        headerHeight: headerHeight
                                    )
                                }
                            }
                            .frame(width: pianoKeysWidth)
                        }
                    }
                }
            }
            .overlay(alignment: .trailing) {
                if showInspector {
                    RollInspectorView(
                        rollViewModel: rollViewModel,
                        presentedView: $presentedView,
                        widthScale: $widthScale,
                        parts: rollViewModel.parts
                    )
                    .frame(width: inspectorWidth)
                    .transition(.move(edge: .trailing))
                }
            }
            .overlay(alignment: .topTrailing) {
                InspectorButton(
                    showInspector: $showInspector,
                    headerHeight: headerHeight
                )
            }
        }
    }
}

#Preview {
    RollView(presentedView: Binding.constant(.Roll), rollViewModel: RollViewModel(), octaves: 9)
}
