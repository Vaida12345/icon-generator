//
//  ContentView.swift
//  waifuExtension
//
//  Created by Vaida on 11/22/21.
//

import SwiftUI
import AVFoundation

func addItems(of items: [FinderItem], to finderItems: [FinderItem]) -> [FinderItem] {
    var finderItems = finderItems
    var counter = 0
    while counter < items.count {
        autoreleasepool {
            finderItems = addItemIfPossible(of: items[counter], to: finderItems)
            
            counter += 1
        }
    }
    return finderItems
}

func addItemIfPossible(of item: FinderItem, to finderItems: [FinderItem]) -> [FinderItem] {
    guard !finderItems.contains(item) else { return finderItems }
    var finderItems = finderItems
    if item.isFile {
        guard item.image != nil else { return finderItems }
        finderItems.append(item)
    } else {
        item.iteratedOver { child in
            autoreleasepool {
                guard !finderItems.contains(child) else { return }
                guard child.image != nil else { return }
                child.relativePath = item.fileName! + "/" + child.relativePath(to: item)!
                finderItems = addItemIfPossible(of: child, to: finderItems)
            }
        }
    }
    return finderItems
}

struct ContentView: View {
    @State var finderItems: [FinderItem] = []
    @State var isSheetShown: Bool = false
    @State var chosenOption: String = "Normal"
    
    var body: some View {
        VStack {
            HStack {
                if !finderItems.isEmpty {
                    Button("Remove All") {
                        withAnimation {
                            finderItems = []
                        }
                    }
                    .padding([.leading, .vertical])
                }
                
                Button("Add Item") {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseDirectories = true
                    if panel.runModal() == .OK {
                        for i in panel.urls {
                            finderItems = addItemIfPossible(of: FinderItem(at: i), to: finderItems)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Menu(chosenOption) {
                    ForEach(["Normal", "Xcode Mac", "Xcode iPhone"], id: \.self) { item in
                        Button(item) {
                            chosenOption = item
                        }
                    }
                }
                .frame(width: 120)
                
                Button("Done") {
                    isSheetShown = true
                }
                .disabled(finderItems.isEmpty || isSheetShown)
                .padding([.top, .bottom, .trailing])
            }
            
            if finderItems.isEmpty {
                welcomeView(finderItems: $finderItems)
            } else {
                GeometryReader { geometry in
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5)) {
                            ForEach(finderItems) { item in
                                GridItemView(finderItems: $finderItems, item: item, geometry: geometry)
                            }
                        }
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            for i in providers {
                i.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, error in
                    guard error == nil else { return }
                    guard let urlData = urlData as? Data else { return }
                    guard let url = URL(dataRepresentation: urlData, relativeTo: nil) else { return }
                    
                    let item = FinderItem(at: url)
                    finderItems = addItemIfPossible(of: item, to: finderItems)
                }
            }
            
            return true
        }
        .sheet(isPresented: $isSheetShown) {
            self.finderItems = []
        } content: {
            ProcessingView(finderItems: $finderItems, isAppear: $isSheetShown, option: $chosenOption)
                .frame(width: 600, height: 150)
        }
        .onDisappear {
            do {
                try FinderItem(at: "\(NSHomeDirectory())/tmp").removeFile()
            } catch {
                
            }
        }
        .onAppear {
            do {
                try FinderItem(at: "\(NSHomeDirectory())/tmp").removeFile()
            } catch {
                
            }
        }
    }
}

struct welcomeView: View {
    
    @Binding var finderItems: [FinderItem]
    
    var body: some View {
        VStack {
            Image(systemName: "square.and.arrow.down.fill")
                .resizable()
                .scaledToFit()
                .padding(.all)
                .frame(width: 100, height: 100, alignment: .center)
            Text("Drag files or folder \n or \n Click to add files.")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.all)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.all, 0.0)
        .onTapGesture(count: 2) {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = true
            panel.canChooseDirectories = true
            if panel.runModal() == .OK {
                for i in panel.urls {
                    let item = FinderItem(at: i)
                    finderItems = addItemIfPossible(of: item, to: finderItems)
                }
                
            }
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            for i in providers {
                i.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, error in
                    
                    guard error == nil else { return }
                    guard let urlData = urlData as? Data else { return }
                    guard let url = URL(dataRepresentation: urlData, relativeTo: nil) else { return }
                    
                    let item = FinderItem(at: url)
                    finderItems = addItemIfPossible(of: item, to: finderItems)
                }
            }
            
            return true
        }
    }
}


struct GridItemView: View {
    
    @Binding var finderItems: [FinderItem]
    
    @State var isShowingHint: Bool = false
    @State var image: NSImage = NSImage(named: "placeholder")!
    @State var isShowingAlert: Bool = false
    
    let item: FinderItem
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .center) {
            
            Image(nsImage: image)
                .resizable()
                .cornerRadius(5)
                .aspectRatio(contentMode: .fit)
                .padding([.top, .leading, .trailing])
                .popover(isPresented: $isShowingHint) {
                    Text(image != NSImage(named: "placeholder")! ?
                        """
                        name: \(item.fileName ?? "???")
                        path: \(item.path)
                        size: \(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!.width) × \(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!.height)
                        """
                         :
                        """
                        Loading...
                        name: \(item.fileName ?? "???")
                        path: \(item.path)
                        """)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .popover(isPresented: $isShowingAlert) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                        Text("This image is not 1: 1")
                            .frame(width: 150)
                    }
                    .padding()
                }
            
            Text(((item.relativePath ?? item.fileName) ?? item.path))
                .multilineTextAlignment(.center)
                .padding([.leading, .bottom, .trailing])
                .lineLimit(1)
                .onHover { bool in
                    self.isShowingHint = bool
                }
        }
        .frame(width: geometry.size.width / 5, height: geometry.size.width / 5)
        .contextMenu {
            Button("Open") {
                print(item.path)
                _ = shell(["open \(item.shellPath)"])
            }
            Button("Show in Finder") {
                _ = shell(["open \(item.shellPath) -R"])
            }
            Button("Delete") {
                withAnimation {
                    _ = finderItems.remove(at: finderItems.firstIndex(of: item)!)
                }
            }
        }
        .onAppear {
            DispatchQueue(label: "background").async {
                image = item.image ?? NSImage(named: "placeholder")!
                if image.cgImage(forProposedRect: nil, context: nil, hints: nil)!.width != image.cgImage(forProposedRect: nil, context: nil, hints: nil)!.height {
                    isShowingAlert = true
                }
            }
        }
    }
}

struct ProcessingView: View {
    
    @Binding var finderItems: [FinderItem]
    @Binding var isAppear: Bool
    @Binding var option: String
    
    @State var isFinished: Bool = false
    @State var progress: Double = 0
    
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
                    
                    Button("Show in Finder") {
                        shell(["open \(FinderItem(at: "\(NSHomeDirectory())/Downloads/icon Output").shellPath) -R"])
                    }
                    .padding(.trailing)
                    
                    Button("Done") {
                        isAppear = false
                    }
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
        .onAppear {
            DispatchQueue(label: "background").async {
                for i in finderItems {
                    let path = FinderItem(at: "\(NSHomeDirectory())/tmp/\(i.relativePath ?? i.fileName! + i.extensionName!)").generateOutputPath()
                    FinderItem(at: path).generateDirectory()
                    try! i.copy(to: path)
                }
                
                FinderItem.createIcon(at: FinderItem(at: "\(NSHomeDirectory())/tmp"), option: option) { progress in
                    self.progress = progress
                } completion: {
                    isFinished = true
                    do {
                        try FinderItem(at: "\(NSHomeDirectory())/Downloads/icon Output").removeFile()
                    } catch {
                        
                    }
                    try! FinderItem(at: "\(NSHomeDirectory())/tmp").copy(to: "\(NSHomeDirectory())/Downloads/icon Output")
                    try! FinderItem(at: "\(NSHomeDirectory())/tmp").removeFile()
                    if option == "Normal" {
                        FinderItem(at: "\(NSHomeDirectory())/Downloads/icon Output").iteratedOver { child in
                            if child.extensionName != ".icns" {
                                try! child.removeFile()
                            }
                        }
                    }
                    try! FinderItem(at: "\(NSHomeDirectory())/Downloads/icon Output").setIcon(image: NSImage(imageLiteralResourceName: "icon"))
                }

            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
