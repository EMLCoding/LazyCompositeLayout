//
//  ImageModel.swift
//  LazyCompositionalLayout
//
//  Created by Eduardo Martin Lorenzo on 25/6/22.
//

import SwiftUI

struct ImageModel: Identifiable, Codable, Hashable {
    var id: String
    var downloadUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case downloadUrl = "download_url"
    }
}
