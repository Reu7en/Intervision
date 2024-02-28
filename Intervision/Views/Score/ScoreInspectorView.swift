//
//  ScoreInspectorView.swift
//  Intervision
//
//  Created by Reuben on 27/02/2024.
//

import SwiftUI

struct ScoreInspectorView: View {
    
    @Binding var presentedView: HomeView.PresentedView
    
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
                withAnimation(.easeInOut(duration: 0.75)) {
                    presentedView = newValue
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
    ScoreInspectorView(presentedView: Binding.constant(.Score))
}
