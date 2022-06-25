//
//  ImageVM.swift
//  LazyCompositionalLayout
//
//  Created by Eduardo Martin Lorenzo on 25/6/22.
//

import SwiftUI

final class ImageVM: ObservableObject {
    @Published var fetchedImages: [ImageModel]?
    
    @Published var currentPage = 0
    @Published var startPagination = false
    @Published var endPagination = false
    
    init() {
        updateImages()
    }
    
    func updateImages() {
        currentPage += 1
        Task {
            do {
                try await fetchImages()
            } catch {
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func fetchImages() async throws {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=\(currentPage)&limit=30") else { return }
        
        let response = try await URLSession.shared.data(from: url)
        // La API permite pedir imagenes en un tamaño en concreto
        let images = try JSONDecoder().decode([ImageModel].self, from: response.0).compactMap({ item -> ImageModel? in
            let imageID = item.id
            let sizedUrl = "https://picsum.photos/id/\(imageID)/500/500"
            return .init(id: imageID, downloadUrl: sizedUrl)
        })
        if fetchedImages == nil { fetchedImages = []}
        fetchedImages?.append(contentsOf: images)
        endPagination = (fetchedImages?.count ?? 0) > 100
        startPagination = false
    }
}
