//
//  HabitsController.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 03.10.25.
//

import Foundation
import Vapor
import HabitTrackerAppSharedDTO

struct HabitsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        
        // /api/:userId
        let api = routes.grouped("api", ":userId")
        
        // POST: saving a habbit category
        // /api/:userId/categories
        api.post("categories", use: saveHabitCategory)
    }
    
    @Sendable func saveHabitCategory(req: Request) async throws -> HabitsCategoryResponseDTO {
        
        // get the user id
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid userId parameter")
        }
        
        // Decode request as a simple dictionary to get name and colorCode
        let requestData = try req.content.decode([String: String].self)
        guard let name = requestData["name"],
              let colorCode = requestData["colorCode"] else {
            throw Abort(.badRequest, reason: "Missing required fields: name and colorCode")
        }
        
        let habitCategory = Category(
            name: name,
            colorCode: colorCode,
            userId: userId
        )
        try await habitCategory.save(on: req.db)
        
        // After saving, ensure the ID is assigned
        guard habitCategory.id != nil else {
            throw Abort(.internalServerError, reason: "Failed to get ID after saving category")
        }
        
        // DTO for the response
        guard let categoryResponseDTO = HabitsCategoryResponseDTO(habitCategory) else {
            throw Abort(.internalServerError, reason: "Failed to create response DTO")
        }
        
        return categoryResponseDTO
    }
        
}
