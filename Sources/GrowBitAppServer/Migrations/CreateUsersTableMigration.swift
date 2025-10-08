//
//  CreateUsersTableMigration.swift.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 24.09.25.
//

import Foundation
import Fluent

struct CreateUsersTableMigration: AsyncMigration {
   
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required).unique(on: "username")
            .field("password", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .delete()
    }
}