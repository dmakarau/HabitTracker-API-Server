//
//  CreateCategoryTableMigration.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 03.10.25.
//

import Foundation
import Fluent

struct CreateCategoryTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("categories")
            .id()
            .field("name", .string, .required)
            .field("color_code", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("categories")
            .delete()
    }
}

