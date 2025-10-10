//
//  CreateItemsTableMigration.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 10.10.25.
//

import Foundation
import Fluent

struct CreateItemsTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("items")
            .id()
            .field("title", .string, .required)
            .field("description", .string)
            .field("start_data", .date, .required)
//            .field("frequency", .enum(type: "item_frequency"), .required)
            .field("category_id", .uuid, .required, .references("habits_categories", "id", onDelete: .cascade))
            .create()
        
    }
    
    func revert(on database: any Database) async throws {
    }

}
