//
//  GrowBitAppServerDeleteCategoryTests.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 08.10.25.
//

@testable import GrowBitAppServer
import VaporTesting
import GrowBitSharedDTO
import Testing
import Fluent

@Suite("Category Deletion Tests")
struct GrowBitAppServerDeleteCategoryTests {

    @Test("Delete category - Success")
    func deleteCategorySuccess() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "deleteuser1", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            // Retrieve the created user
            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "deleteuser1")
                .first(),
                  let userId = createdUser.id else {
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

            // Delete the category
            try await app.testing().test(.DELETE, "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)") { req in
                // No body needed for DELETE request
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(CategoryResponseDTO.self)
                #expect(response.id == unwrappedCategoryId)
                #expect(response.name == "Test Category")
                #expect(response.colorCode == "#FF0000")
            }

            // Verify the category was actually deleted from the database
            let deletedCategory = try await Category.query(on: app.db)
                .filter(\.$id == unwrappedCategoryId)
                .first()
            #expect(deletedCategory == nil)
        }
    }

    @Test("Delete category - Verify category is removed from list")
    func deleteCategoryVerifyRemoval() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "deleteuser2", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            // Retrieve the created user
            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "deleteuser2")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Create multiple categories
            let categories = [
                ["name": "Work", "colorCode": "#FF0000"],
                ["name": "Personal", "colorCode": "#00FF00"],
                ["name": "Health", "colorCode": "#0000FF"]
            ]

            var categoryIds: [UUID] = []
            for category in categories {
                try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                    try req.content.encode(category)
                } afterResponse: { res in
                    #expect(res.status == .ok)
                    let response = try res.content.decode(CategoryResponseDTO.self)
                    categoryIds.append(response.id)
                }
            }

            #expect(categoryIds.count == 3)

            // TODO(human)
            // Delete the category
            try await app.testing().test(.DELETE, "/api/\(userId.uuidString)/categories/\(categoryIds[1].uuidString)") { req in
                // No body needed for DELETE request
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(CategoryResponseDTO.self)
                #expect(response.id == (categoryIds[1]))
                #expect(response.name == "Personal")
                #expect(response.colorCode == "#00FF00")
            }
            
            // Verify the category was actually deleted from the database
            let deletedCategory = try await Category.query(on: app.db)
                .filter(\.$id == categoryIds[1])
                .first()
            #expect(deletedCategory == nil)
            
            // Verify the category still exists for user1
            var category = try await Category.query(on: app.db)
                .filter(\.$id == categoryIds[0])
                .first()
            #expect(category != nil)
            
            // Verify the category still exists for user1
            category = try await Category.query(on: app.db)
                .filter(\.$id == categoryIds[2])
                .first()
            #expect(category != nil)
        }
        
    }

    @Test("Delete category - Fail - Invalid categoryId")
    func deleteCategoryInvalidCategoryId() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "deleteuser3", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            // Retrieve the created user
            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "deleteuser3")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Try to delete with invalid category UUID format
            try await app.testing().test(.DELETE, "/api/\(userId.uuidString)/categories/invalid-uuid") { req in
                // No body needed for DELETE request
            } afterResponse: { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Delete category - Fail - Non-existent categoryId")
    func deleteCategoryNonExistentCategoryId() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "deleteuser4", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            // Retrieve the created user
            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "deleteuser4")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Try to delete a category that doesn't exist (valid UUID format but doesn't exist)
            let nonExistentId = UUID()
            try await app.testing().test(.DELETE, "/api/\(userId.uuidString)/categories/\(nonExistentId.uuidString)") { req in
                // No body needed for DELETE request
            } afterResponse: { res in
                #expect(res.status == .notFound)
                #expect(res.body.string.contains("Category not found"))
            }
        }
    }

    @Test("Delete category - Fail - Invalid userId")
    func deleteCategoryInvalidUserId() async throws {
        try await withApp(configure: configure) { app in
            // Create a user and category
            let userRequestBody = User(username: "deleteuser5", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "deleteuser5")
                .first(),
                  let userId = createdUser.id else {
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
            }

            guard let unwrappedCategoryId = categoryId else {
                throw TestError.userCreationFailed
            }

            // Try to delete with invalid user UUID format
            try await app.testing().test(.DELETE, "/api/invalid-uuid/categories/\(unwrappedCategoryId.uuidString)") { req in
                // No body needed for DELETE request
            } afterResponse: { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Delete category - User isolation test")
    func deleteCategoryUserIsolation() async throws {
        try await withApp(configure: configure) { app in
            // Create two users
            let userRequestBody1 = User(username: "deleteuser6a", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody1)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            let userRequestBody2 = User(username: "deleteuser6b", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody2)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            // Retrieve both users
            guard let createdUser1 = try await User.query(on: app.db)
                .filter(\.$username == "deleteuser6a")
                .first(),
                  let userId1 = createdUser1.id else {
                throw TestError.userCreationFailed
            }

            guard let createdUser2 = try await User.query(on: app.db)
                .filter(\.$username == "deleteuser6b")
                .first(),
                  let userId2 = createdUser2.id else {
                throw TestError.userCreationFailed
            }

            // Create a category for user1
            let categoryRequestBody = [
                "name": "User1 Category",
                "colorCode": "#FF0000"
            ]

            var user1CategoryId: UUID?
            try await app.testing().test(.POST, "/api/\(userId1.uuidString)/categories") { req in
                try req.content.encode(categoryRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(CategoryResponseDTO.self)
                user1CategoryId = response.id
            }

            guard let unwrappedUser1CategoryId = user1CategoryId else {
                throw TestError.userCreationFailed
            }

            // Try to delete user1's category using user2's userId
            try await app.testing().test(.DELETE, "/api/\(userId2.uuidString)/categories/\(unwrappedUser1CategoryId.uuidString)") { req in
                // No body needed for DELETE request
            } afterResponse: { res in
                #expect(res.status == .notFound)
                #expect(res.body.string.contains("Category not found"))
            }

            // Verify the category still exists for user1
            let category = try await Category.query(on: app.db)
                .filter(\.$id == unwrappedUser1CategoryId)
                .filter(\.$user.$id == userId1)
                .first()
            #expect(category != nil)
        }
    }
}
