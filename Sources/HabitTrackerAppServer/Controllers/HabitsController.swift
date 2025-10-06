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
        // DTO for the request
        let habitsCategoryRequestDTO = try req.content.decode(HabitsCategoryRequestDTO.self)
        
        let habitCategory = Category(
            name: habitsCategoryRequestDTO.name,
            colorCode: habitsCategoryRequestDTO.colorCode,
            userId: userId
        )
        try await habitCategory.save(on: req.db)
        
        // DTO for thre response
        
        guard let categoryResponseDTO = HabitsCategoryResponseDTO(habitCategory) else {
            throw Abort(.internalServerError, reason: "Failed to create response DTO")
        }
        
        return categoryResponseDTO
    }
        
}
