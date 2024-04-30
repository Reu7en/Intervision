//
//  ScoreThreeNoteInnerIntervalsIdentificationView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct ScoreThreeNoteInnerIntervalsIdentificationView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("ScoreThreeNoteInnerIntervalsIdentification")
                    .font(.title)
                
                if let session = testingViewModel.testSession {
                    let question = session.questions[testingViewModel.currentQuestion]
                    
                    if let questionData = testingViewModel.generateQuestionData(question: question),
                       let barViewModel = questionData.0,
                       let answer = questionData.2 {
                        
                        HStack {
                            Spacer()
                            
                            BarView(barViewModel: barViewModel)
                                .frame(width: geometry.size.width / 2, height: geometry.size.height / 5)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Material.ultraThickMaterial)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .shadow(radius: 10)
                                )
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Text(String(describing: answer))
                            
                            Spacer()
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Text("Identify the intervals between the following:\n1. The lowest note and the middle note.\n2. The middle note and the highest note.")
                        .font(.title2)
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    
                    Text("\(testingViewModel.currentQuestion + 1)/\(testingViewModel.questionCount)")
                        .font(.title3)
                    
                    Spacer()
                }
                
                Spacer()
                
                NextQuestionButton(testingViewModel: testingViewModel)
            }
        }
    }
}

#Preview {
    ScoreThreeNoteInnerIntervalsIdentificationView(testingViewModel: TestingViewModel())
}
