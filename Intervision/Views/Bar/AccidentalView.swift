//
//  AccidentalView.swift
//  Intervision
//
//  Created by Reuben on 02/04/2024.
//

import SwiftUI

struct AccidentalView: View {
    
    let accidental: Note.Accidental
    
    var body: some View {
        switch accidental {
        case .Sharp:
            Image("Sharp")
                .interpolation(.high)
                .resizable()
                .scaledToFit()
        case .Flat:
            Image("Flat")
                .interpolation(.high)
                .resizable()
                .scaledToFit()
        case .Natural:
            Image("Natural")
                .interpolation(.high)
                .resizable()
                .scaledToFit()
        case .DoubleSharp:
            Circle()
                .fill(.red)
        case .DoubleFlat:
            Circle()
                .fill(.blue)
        }
    }
}

#Preview {
    AccidentalView(accidental: .Natural)
}
