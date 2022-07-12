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
    
    @AppStorage("generates into folder") private var generatesIntoFolder = true
    
    var body: some View {
        VStack {
            
            if finderItems.isEmpty {
                DropView { items in
                    withAnimation {
                        finderItems.formUnion(items.filter { $0.image != nil })
                    }
                }
            } else {
                GeometryReader { geometry in
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5)) {
                            ForEach(finderItems) { item in
                                GridItemView(finderItems: $finderItems, item: item, geometry: geometry)
                                    .onDrag {
                                        item.itemProvider!
                                    }
                            }
                        }
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            
            Task {
                let items = await [FinderItem](from: providers)
                withAnimation {
                    finderItems.formUnion(items.filter { $0.image != nil })
                }
            }
            
            return true
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
                if !generatesIntoFolder && isGenerating && progress != 1 {
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
                Button("Done") {
                    DispatchQueue.global().async {
                        if generatesIntoFolder {
                            isSheetShown = true
                        } else {
                            isGenerating = true
                            finderItems.process(option: chosenOption, isFinished: $isFinished, progress: $progress.animation(), generatesIntoFolder: false)
                        }
                    }
                }
                .disabled(finderItems.isEmpty || isSheetShown || isGenerating)
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
