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
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .center) {
            
            if let image = item.image {
                Image(nsImage: image)
                    .resizable()
                    .cornerRadius(5)
                    .aspectRatio(contentMode: .fit)
                    .padding([.top, .leading, .trailing])
                    .popover(isPresented: $isShowingHint) {
                        Text {
                        """
                        name: \(item.fileName)
                        path: \(item.path)
                        size: \(image.pixelSize != nil ? image.pixelSize!.width.description + "x" + image.pixelSize!.height.description : "???")
                        """
                        }
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
    }
}
