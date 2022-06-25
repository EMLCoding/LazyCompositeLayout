//
//  ContentView.swift
//  LazyCompositionalLayout
//
//  Created by Eduardo Martin Lorenzo on 25/6/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var imageVM: ImageVM = .init()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    if let images = imageVM.fetchedImages {
                        ScrollView {
                            CompositionalView(items: images, id: \.self) { item in
                                GeometryReader { proxy in
                                    let size = proxy.size
                                    AsyncImage(url: URL(string: item.downloadUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: size.width, height: size.height)
                                            .cornerRadius(10)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .onAppear {
                                        if images.last?.id == item.id {
                                            imageVM.startPagination = true
                                        }
                                    }
                                }
                            }
                            .padding()
                            .padding(.bottom, 10)
                            
                            if imageVM.startPagination && !imageVM.endPagination {
                                ProgressView()
                                    .offset()
                                    .onAppear {
                                        Task {
                                            imageVM.updateImages()
                                        }
                                    }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
                .navigationTitle("Diseño compositivo")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
