//
//  CreateHabitsTableMigration.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 10.10.25.
//

import Foundation
import Fluent

struct CreateHabitsTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema
    }
    
    func revert(on database: any Database) async throws {
    }

}
