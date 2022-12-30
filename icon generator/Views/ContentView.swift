//
//  ContentView.swift
//
//
//  Created by Vaida on 11/22/21.
//

import SwiftUI
import AVFoundation
import Support


struct ContentView: View {
    @State var finderItems: [FinderItem] = []
    @State var isSheetShown: Bool = false
    @State var chosenOption: Options = .normal
    
    @State private var progress = 0.0
    @State private var isGenerating = false
    @State private var isFinished = false
    
    @AppStorage("mode") private var mode: ProcessMode = .export
    
    @State private var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            DropView(disabled: mode == .noneDestination && isFinished, isShowingPrompt: finderItems.isEmpty) {
                $0.image != nil
            } handler: { items in
                if mode == .auto {
                    Task {
                        do {
                            await finderItems.append(contentsOf: try items.process(option: chosenOption, isFinished: $isFinished, progress: $progress, generatesIntoFolder: false))
                        } catch {
                            alertManager = AlertManager(error: error)
                        }
                    }
                } else {
                    finderItems.append(contentsOf: items)
                }
            } content: {
                GeometryReader { geometry in
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5)) {
                            ForEach(finderItems) { item in
                                GridItemView(finderItems: $finderItems, item: item, geometry: geometry, isFinished: isFinished, option: chosenOption)
                            }
                        }
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .alert(manager: $alertManager)
        }
        .sheet(isPresented: $isSheetShown) {
            withAnimation {
                self.finderItems = []
            }
        } content: {
            ProcessingView(finderItems: finderItems, option: chosenOption)
                .frame(width: 600, height: 150)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                if !finderItems.isEmpty {
                    Button("Remove All") {
                        withAnimation {
                            finderItems.removeAll()
                            
                            progress = 0
                            isFinished = false
                            isGenerating = false
                        }
                    }
                }
            }
            
            ToolbarItem {
                if mode == .noneDestination && isGenerating && progress != 1 {
                    ProgressView(value: self.progress)
                        .progressViewStyle(.circular)
                }
            }
            
            ToolbarItem {
                Menu(chosenOption.rawValue) {
                    ForEach(Options.allCases, id: \.self) { item in
                        Button(item.rawValue) {
                            chosenOption = item
                        }
                    }
                }
                .frame(width: 120)
            }
            
            ToolbarItem {
                if mode != .auto {
                    Button("Done") {
                        Task {
                            if mode == .export {
                                isSheetShown = true
                            } else {
                                isGenerating = true
                                do {
                                    try await finderItems.process(option: chosenOption, isFinished: $isFinished, progress: $progress.animation(), generatesIntoFolder: false)
                                } catch {
                                    alertManager = AlertManager(error: error)
                                }
                            }
                        }
                    }
                    .disabled(finderItems.isEmpty || isSheetShown || isGenerating)
                }
            }
        }
    }
    
    enum Options: String, CaseIterable {
        case normal = "Normal"
        case xcodeMac = "Xcode Mac"
        case xcodeFull = "Xcode Full"
        case customImage = "Custom Image"
    }
}
