//
//  ResultsView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

struct ResultsView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var showExitAlert = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    testingViewModel.saveTestSession()
                } label: {
                    Text("Save Results")
                        .font(.title)
                        .padding()
                }
                .alert(isPresented: $testingViewModel.showSavingSuccessAlert) {
                    Alert(
                        title: Text("Saved"),
                        message: Text("Your test data has been saved successfully! 🎉")
                    )
                }
                .alert(isPresented: $testingViewModel.showSavingErrorAlert) {
                    Alert(
                        title: Text("Error!"),
                        message: Text("Test data has not been saved!")
                    )
                }
                #if os(iOS)
                .sheet(item: $testingViewModel.resultsURL) { identifiableURL in
                    ActivityView(activityItems: [identifiableURL.url], applicationActivities: nil)
                }
                #endif
                
                Spacer()
            }
            
            Spacer()
        }
        .overlay(alignment: .topLeading) {
            Button {
                self.showExitAlert = true
                
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .padding()
            }
        }
        .alert("Are you sure you want to exit?", isPresented: $showExitAlert) {
            Button {
                testingViewModel.presentedView = .Registration
            } label: {
                Text("Yes")
            }
            
            Button {
                
            } label: {
                Text("No")
            }
        }
    }
}

#Preview {
    ResultsView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}

#if os(iOS)
struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
