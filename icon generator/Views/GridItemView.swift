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
                        name: \(item.fileName)
                        path: \(item.path)
                        size: \(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!.width) × \(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!.height)
                        """
                         :
                        """
                        Loading...
                        name: \(item.fileName)
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
            
            Text(item.relativePath ?? item.fileName)
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
                item.open()
            }
            Button("Show in Finder") {
                item.revealInFinder()
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
