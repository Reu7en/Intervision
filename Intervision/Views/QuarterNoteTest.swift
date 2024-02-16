import SwiftUI

struct FilledNoteHead: View {
    var color: Color

    private let aspectRatio: CGFloat = 1.25
    private let rotationAngle: CGFloat = -30.0

    var body: some View {
        GeometryReader { geometry in
            let noteHeight = geometry.size.height
            let noteWidth = noteHeight * aspectRatio
            let xOffset = (geometry.size.width - noteWidth) / 2
            let yOffset = (geometry.size.height - noteHeight) / 2

            Path { path in
                path.addEllipse(in: CGRect(x: xOffset, y: yOffset, width: noteWidth, height: noteHeight))
            }
            .fill(color)
            .rotationEffect(.degrees(rotationAngle))
        }
    }
}

struct QuarterNoteGrid: View {
    let rows = 40
    let columns = 40

    var body: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row in
                HStack {
                    ForEach(0..<columns, id: \.self) { column in
                        FilledNoteHead(color: .red)
                            .aspectRatio(1, contentMode: .fit) // Maintain the aspect ratio within the grid cell
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .border(Color.blue, width: 1) // Border around the entire grid
    }
}

struct ContentView: View {
    var body: some View {
        QuarterNoteGrid()
            .padding() // Add padding around the grid for visibility
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
