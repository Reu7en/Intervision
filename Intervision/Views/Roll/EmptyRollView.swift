//
//  EmptyRollView.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI

struct EmptyRollView: View {
    
    let geometry: GeometryProxy
    
    var body: some View {
        Color.clear
            .frame(width: geometry.size.width)
    }
}

#Preview {
    GeometryReader { geometry in
        EmptyRollView(geometry: geometry)
    }
}
