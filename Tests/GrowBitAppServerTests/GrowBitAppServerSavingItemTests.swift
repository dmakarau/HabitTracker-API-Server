//
//  GrowBitAppServerSavingItemTests.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 10.10.25.
//

@testable import GrowBitAppServer
import VaporTesting
import GrowBitSharedDTO
import Testing
import Fluent

@Suite("Item Creation Tests")
struct GrowBitAppServerSavingItemTests {
    
    @Test("Item creation - Success")
    func testItemCreationSuccess() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_item", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(RegisterResponseDTO.self)
                #expect(response.error == false)
            }
            
            // Retrieve the created user from the database
            guard let createdUserForItem = try await User.query(on: app.db)
                .filter(\.$username == "testuser_item")
                .first(),
                  let userId = createdUserForItem.id else {
                throw TestError.userCreationFailed
            }
            
            // Create a category
            let categoryRequestBody = [
                "name": "Test Category",
                "colorCode": "#FF0000"
            ]
            
            var categoryId: UUID?
            try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                try req.content.encode(categoryRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(CategoryResponseDTO.self)
                categoryId = response.id
                #expect(response.name == "Test Category")
            }
            
            guard let unwrappedCategoryId = categoryId else {
                throw TestError.userCreationFailed
            }
            
            // Now create an item in the created category
            
            let itemRequestBody = ItemRequestDTO(
                title: "Test Item",
                description: "This is a test item",
                startDate: Date(),
                frequency: .daily,
                goalDays: 30,
                categoryId: unwrappedCategoryId
            )
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBody)
                } afterResponse: { res in
                    #expect(res.status == .ok)
                    let response = try res.content.decode(ItemResponseDTO.self)
                    #expect(response.title == "Test Item")
                    #expect(response.frequency == .daily)
                    #expect(response.goalDays == 30)
                }
        }
    }
}


