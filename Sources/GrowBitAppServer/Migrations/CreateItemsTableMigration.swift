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
        
        let frequency = try await database.enum("item_frequency")
                   .case("daily")
                   .case("weekly")
                   .case("monthly")
                   .create()
        
        try await database.schema("items")
            .id()
            .field("title", .string, .required)
            .field("description", .string)
            .field("start_date", .date, .required)
            .field("frequency", frequency, .required)
            .field("goal_days", .int, .required)
            .field("completed_days", .int, .required)
            .field("is_completed", .bool, .required, .custom("DEFAULT FALSE"))
            .field("category_id", .uuid, .required, .references("categories", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("items").delete()
        try await database.enum("item_frequency").delete()
    }

}
