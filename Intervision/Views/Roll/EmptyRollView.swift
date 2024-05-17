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
        GeometryReader { geometry in
            Spacer()
        }
    }
}

#Preview {
    GeometryReader { geometry in
        EmptyRollView(geometry: geometry)
    }
}
