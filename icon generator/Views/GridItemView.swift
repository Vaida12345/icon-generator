//
//  GridItemView.swift
//  icon generator
//
//  Created by Vaida on 6/6/22.
//

import Foundation
import SwiftUI
import Support


struct GridItemView: View {
    
    @Binding var finderItems: [FinderItem]
    
    @State var isShowingHint: Bool = false
    @State var isShowingAlert: Bool = false
    
    let item: FinderItem
    let isFinished: Bool
    let option: ContentView.Options
    
    var image: NativeImage? {
        return item.image ?? item.with(subPath: "icon_1024x1024.png").image
    }
    
    @AppStorage("mode") private var mode: ProcessMode = .export
    
    var body: some View {
        VStack(alignment: .center) {
            
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .cornerRadius(5)
                    .aspectRatio(contentMode: .fit)
                    .padding([.top, .leading, .trailing])
//                    .popover(isPresented: $isShowingHint) {
//                        Text {
//                        """
//                        name: \(item.fileName)
//                        path: \(item.path)
//                        size: \(image.pixelSize != nil ? image.pixelSize!.width.description + "x" + image.pixelSize!.height.description : "???")
//                        """
//                        }
//                        .multilineTextAlignment(.center)
//                        .padding()
//                    }
            }
            
            Text(item.relativePath ?? item.stem)
                .multilineTextAlignment(.center)
                .padding([.leading, .bottom, .trailing])
                .lineLimit(1)
        }
//        .frame(width: geometry.size.width / 5, height: geometry.size.width / 5)
        .contextMenu {
            Button("Open") {
                Task {
                    try item.open()
                }
            }
            Button("Show in Finder") {
                Task {
                    try item.reveal()
                }
            }
            Button("Delete") {
                withAnimation {
                    _ = finderItems.remove(at: finderItems.firstIndex(of: item)!)
                }
            }
        }
        .onHover { bool in
            self.isShowingHint = bool
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
        .dragHander(isFinished: isFinished, item: item, allItems: $finderItems, mode: mode, option: option)
    }
}

private extension View {
    
    @ViewBuilder
    func dragHander(isFinished: Bool, item: FinderItem, allItems: Binding<[FinderItem]>, mode: ProcessMode, option: ContentView.Options) -> some View {
        if isFinished && mode == .export || mode == .auto {
            onDrag {
                allItems.wrappedValue.removeAll { $0 == item }
                return item.itemProvider!
            }
        } else {
            self
        }
    }
    
}
