//
//  ShopItemsListScreen.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 09/04/2024.
//

import SwiftUI
import SwiftData

struct ShopItemsListScreen: View {
    
    @StateObject var viewModel = ShopItemsListScreenViewModel()
    
    @Environment(\.modelContext) private var context
    
    @Query private var shopItems: [SDShopItem]
    
    var body: some View {
        
        VStack {
            Text("Add local shop item to the SwiftData")
            Button("Add item") {
                addItem()
            }
            List {
                ForEach(shopItems) { item in
                    HStack {
                        Text("\(item.id)")
                        Text(item.title)
                        Button("U") {
                            updateItem(item)
                        }
                    }
                }.onDelete(perform: { indexSet in
                    for index in indexSet {
                        delete(shopItems[index])
                    }
                })
            }
        }
        
        EmptyView()
    }
    
    func updateItem(_ item: SDShopItem) {
        item.title = "Updated Title"
        try? context.save()
    }
    
    func delete(_ item: SDShopItem) {
        context.delete(item)
    }
    
    func addItem() {
        let shopItem = SDShopItem(id: Int.random(in: 1...10000), title: "ShopItem", price: 19.99)
        context.insert(shopItem)
    }
    
    
}

struct ListItemView: View {
    
    var name: String
    var dataSource: ShopItemsListScreenViewModel.ShopItem.DataSource
    
    var body: some View {
        HStack {
            Text(dataSource == .api ? "O" : "C")
            Text(name)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ListItemView(name: "Content Name", dataSource: .persistence)
}

#Preview {
    ShopItemsListScreen()
}
