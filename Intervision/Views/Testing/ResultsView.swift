//
//  ResultsView.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

struct ResultsView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var showExitAlert = false
    
    var body: some View {
        let viewSize = CGSize(width: screenSizeViewModel.screenSize.width / 1.1, height: screenSizeViewModel.screenSize.height / 1.1)
        let cornerRadius = screenSizeViewModel.getEquivalentValue(8)
        let spacing = screenSizeViewModel.getEquivalentValue(20)
        let buttonHeight = screenSizeViewModel.getEquivalentValue(80)
        let buttonWidth = (viewSize.width / 4) - (spacing * 3 / 4)
        
        ZStack {
            VStack {
                Text("Thank you for completing the test!")
                    .equivalentFont(.title)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    testingViewModel.showSavingEmailAlert.toggle()
                } label: {
                    Text("Save Results")
                        .equivalentFont(.title)
                        .fontWeight(.semibold)
                        .frame(width: buttonWidth, height: buttonHeight * 1.5)
                        .background(Color.accentColor)
                        .cornerRadius(cornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
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
                .alert(isPresented: $testingViewModel.showSavingEmailAlert) {
                    Alert(
                        title: Text("Please send your test results to 'Intervision.app@gmail.com'"),
                        message: Text("The email address has been copied to your clipboard"),
                        dismissButton: .default(Text("OK")) {
                            #if os(macOS)
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString("Intervision.app@gmail.com", forType: .string)
                            
                            withAnimation(.easeInOut) {
                                testingViewModel.saveTestSession()
                            }
                            #elseif os(iOS)
                            UIPasteboard.general.string = "Intervision.app@gmail.com"
                            
                            withAnimation(.easeInOut) {
                                testingViewModel.saveTestSession()
                            }
                            #endif
                        }
                    )
                }
                #if os(iOS)
                .sheet(item: $testingViewModel.resultsURL) { identifiableURL in
                    ActivityView(activityItems: [identifiableURL.url])
                }
                #endif
            }
            .frame(width: viewSize.width)
            .overlay(alignment: .topLeading) {
                Button {
                    self.showExitAlert = true
                    
                } label: {
                    Image(systemName: "xmark")
                        .equivalentFont()
                        .equivalentPadding()
                }
            }
            .alert("Are you sure you want to exit?", isPresented: $showExitAlert) {
                Button {
                    withAnimation(.easeInOut) {
                        testingViewModel.presentedView = .Registration
                    }
                } label: {
                    Text("Yes")
                }
                
                Button {
                    
                } label: {
                    Text("No")
                }
            }
        }
        .frame(width: viewSize.width, height: viewSize.height)
        .equivalentPadding(padding: 50)
        .background(
            RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20))
                .fill(Material.ultraThickMaterial)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .overlay {
                    RoundedRectangle(cornerRadius: screenSizeViewModel.getEquivalentValue(20))
                        .fill(Color.gray.opacity(0.2))
                }
                .shadow(radius: screenSizeViewModel.getEquivalentValue(10))
        )
        #if os(macOS)
        .scaleEffect(0.75)
        #endif
    }
}

#Preview {
    ResultsView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
