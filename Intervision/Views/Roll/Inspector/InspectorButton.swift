//
//  InspectorButton.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI

struct InspectorButton: View {
    
    @Binding var showInspector: Bool
    
    let headerHeight: CGFloat
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                showInspector.toggle()
            }
        } label: {
            Image(systemName: "gear")
                .rotationEffect(.degrees(showInspector ? -360 : 0))
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(showInspector ? Color.accentColor : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: headerHeight * 1.5, height: headerHeight * 1)
    }
}

#Preview {
    InspectorButton(showInspector: Binding.constant(true), headerHeight: 50)
}
