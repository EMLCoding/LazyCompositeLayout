//
//  CompositionalView.swift
//  LazyCompositionalLayout
//
//  Created by Eduardo Martin Lorenzo on 25/6/22.
//

import SwiftUI

struct CompositionalView<Content, Item, ID>: View where Content: View, Item: RandomAccessCollection, ID: Hashable, Item.Element: Hashable {
    var content: (Item.Element) -> Content
    var items: Item
    var spacing: CGFloat
    var id: KeyPath<Item.Element, ID>
    
    init(items: Item, spacing: CGFloat = 5, id: KeyPath<Item.Element, ID>, @ViewBuilder content: @escaping (Item.Element) -> Content) {
        self.content = content
        self.id = id
        self.items = items
        self.spacing = spacing
    }
    
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(generateColumns(), id: \.self) { row in
                RowView(row: row)
            }
        }
    }
    
    func layoutType(row: [Item.Element]) -> LayoutType {
        let index = generateColumns().firstIndex { item in
            return item == row
        } ?? 0
        
        var types: [LayoutType] = []
        generateColumns().forEach { _ in
            if types.isEmpty {
                types.append(.type1)
            } else if types.last == .type1 {
                types.append(.type2)
            }else if types.last == .type2 {
                types.append(.type3)
            }else if types.last == .type3 {
                types.append(.type1)
            } else {}
        }
        
        return types[index]
    }
    
    @ViewBuilder
    func RowView(row: [Item.Element]) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = (proxy.size.height - spacing) / 2 // El 2 es porque en una fila como mucho hay dos alturas
            let type = layoutType(row: row)
            let columnWidth = (width > 0 ? ((width - (spacing * 2)) / 3) : 0) // El 3 es porque en una fila como mucho hay 3 elementos seguidos
            
            HStack(spacing: spacing) {
                // Estos diseños es como se quiera colocar los elementos de cada fila segun el tipo de fila
                if type == .type1 {
                    SafeView(row: row, index: 0)
                    VStack(spacing: spacing) {
                        SafeView(row: row, index: 1)
                            .frame(height: height)
                        SafeView(row: row, index: 2)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                }
                
                if type == .type2 {
                    HStack(spacing: spacing) {
                        SafeView(row: row, index: 2)
                            .frame(width: columnWidth)
                        SafeView(row: row, index: 1)
                            .frame(width: columnWidth)
                        SafeView(row: row, index: 0)
                            .frame(width: columnWidth)
                    }
                }
                
                if type == .type3 {
                    VStack(spacing: spacing) {
                        SafeView(row: row, index: 0)
                            .frame(height: height)
                        SafeView(row: row, index: 1)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                    SafeView(row: row, index: 2)
                }
            }
        }
        .frame(height: layoutType(row: row) == .type1 || layoutType(row: row) == .type3 ? 250 : 120)
    }
    
    @ViewBuilder
    func SafeView(row: [Item.Element], index: Int) -> some View {
        if (row.count - 1) >= index {
            content(row[index])
        }
    }
    
    func generateColumns() -> [[Item.Element]] {
        var columns: [[Item.Element]] = []
        var row: [Item.Element] = []
        
        for item in items {
            if row.count == 3 {
                columns.append(row)
                row.removeAll()
                row.append(item)
            } else {
                row.append(item)
            }
        }
        
        columns.append(row)
        row.removeAll()
        return columns
    }
}

struct CompositionalView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum LayoutType {
    case type1
    case type2
    case type3
}
