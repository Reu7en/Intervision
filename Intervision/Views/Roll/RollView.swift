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
    
    @State var widthScale: CGFloat = 0.5
    @State var heightScale: CGFloat = 0.75
    @State var showInspector: Bool = false
    @State var showPiano: Bool = true
    @State var showDynamics: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let rows = rollViewModel.octaves * 12
            let pianoKeysWidth = geometry.size.width / 10
            let barWidth = round(geometry.size.width / 3 * widthScale)
            let rowHeight = round(geometry.size.height / CGFloat(rows / 2) * heightScale)
            let headerHeight = geometry.size.height / 30
            let inspectorWidth = geometry.size.width / 8
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    ScrollView([.vertical, .horizontal]) {
                        LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            Section {
                                if let parts = rollViewModel.parts, parts.indices.contains(0),
                                   let segments = rollViewModel.segments {
                                    ForEach(0..<parts[0].bars.count, id: \.self) { barIndex in
                                        if let bar = parts[0].bars[barIndex].first {
                                            let (beats, noteValue) = RollViewModel.getBeatData(bar: bar)
                                            let rowWidth = round(CGFloat(beats) / CGFloat(noteValue) * barWidth)
                                            
                                            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                                Section {
                                                    ZStack {
                                                        BarRowsView(
                                                            rows: rows,
                                                            rowWidth: rowWidth,
                                                            rowHeight: rowHeight,
                                                            beats: beats
                                                        )
                                                        .id(UUID())
                                                        
                                                        IntervalLinesView(
                                                            intervalLinesViewModel: IntervalLinesViewModel(
                                                                segments: segments,
                                                                parts: parts,
                                                                groups: rollViewModel.partGroups,
                                                                harmonicIntervalLinesType: rollViewModel.harmonicIntervalLinesType,
                                                                showMelodicIntervalLines: rollViewModel.showMelodicIntervalLines,
                                                                barIndex: barIndex,
                                                                barWidth: barWidth,
                                                                rowWidth: rowWidth,
                                                                rowHeight: rowHeight,
                                                                harmonicIntervalLineColors: rollViewModel.viewableHarmonicIntervalLineColors,
                                                                melodicIntervalLineColors: rollViewModel.viewableMelodicIntervalLineColors,
                                                                viewableMelodicLines: rollViewModel.viewableMelodicLines,
                                                                showInvertedIntervals: rollViewModel.showInvertedIntervals,
                                                                showZigZags: rollViewModel.showZigZags
                                                            )
                                                        )
                                                        .id(UUID())
                                                        
                                                        RollBarView(
                                                            rollViewModel: rollViewModel,
                                                            segments: segments,
                                                            barIndex: barIndex,
                                                            barWidth: barWidth,
                                                            rowHeight: rowHeight,
                                                            colors: rollViewModel.getSegmentColors(),
                                                            showDynamics: showDynamics
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
                                if showPiano {
                                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                        Section {
                                            PianoKeysView(
                                                geometry: geometry,
                                                octaves: rollViewModel.octaves,
                                                width: pianoKeysWidth,
                                                rowHeight: rowHeight
                                            )
                                            .id(UUID())
                                        } header: {
                                            PianoKeysHeader(
                                                headerHeight: headerHeight
                                            )
                                        }
                                    }
                                    .frame(width: pianoKeysWidth)
                                    .transition(.move(edge: .leading))
                                }
                            }
                        }
                    }
                }
                .frame(width: showInspector ? geometry.size.width - inspectorWidth : geometry.size.width)
            }
            .onAppear {
                rollViewModel.updateRowHeight(rowHeight)
                rollViewModel.updateBarWidth(barWidth)
            }
            
            Spacer()
                .overlay(alignment: .topLeading) {
                    PianoButton(
                        showPiano: $showPiano,
                        headerHeight: headerHeight
                    )
                }
            
            Spacer()
                .overlay(alignment: .trailing) {
                    if showInspector {
                        RollInspectorView(
                            rollViewModel: rollViewModel,
                            presentedView: $presentedView,
                            widthScale: $widthScale,
                            heightScale: $heightScale,
                            showDynamics: $showDynamics,
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
        .onAppear {
            if rollViewModel.parts == nil {
                rollViewModel.addAllParts()
            }
            
            if rollViewModel.partGroups.isEmpty {
                rollViewModel.initialisePartGroups()
            }
            
            rollViewModel.setupEventMonitoring()
        }
        .onDisappear {
            rollViewModel.stopEventMonitoring()
            rollViewModel.clearSelectedSegments()
        }
        .onTapGesture {
            rollViewModel.clearSelectedSegments()
        }
    }
}

#Preview {
    RollView(presentedView: Binding.constant(.Roll), rollViewModel: RollViewModel(scoreManager: ScoreManager()))
}
