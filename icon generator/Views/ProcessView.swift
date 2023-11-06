//
//  ProcessView.swift
//  icon generator
//
//  Created by Vaida on 6/6/22.
//

import Foundation
import SwiftUI
import Support


struct ProcessingView: View {
    
    let finderItems: [FinderItem]
    let option: ContentView.Options
    
    @State var isFinished: Bool = false
    @State var progress: Double = 0
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var alertManager = AlertManager()
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Status: ")
                
                Text(isFinished ? "Finished" : "Processing")
                
                Spacer()
            }
            .padding([.horizontal, .top])
            
            ProgressView(value: isFinished ? 1 : progress)
                .padding([.horizontal, .top])
            
            if isFinished {
                HStack {
                    Spacer()
                    
                    Button {
                        Task {
                            try FinderItem.output.reveal()
                        }
                        dismiss()
                    } label: {
                        Text("Show in Finder")
                            .padding()
                    }
                    .padding(.trailing)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .padding()
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
            } else {
                HStack {
                    Spacer()
                    
                    Button("Cancel") {
                        exit(0)
                    }
                }
                .padding()
            }
        }
        .task {
            do {
                try await finderItems.process(option: self.option, generatesIntoFolder: true)
            } catch {
                alertManager = AlertManager(error: error)
            }
            self.isFinished = true
        }
        .alert(manager: $alertManager)
        
    }
    
}
