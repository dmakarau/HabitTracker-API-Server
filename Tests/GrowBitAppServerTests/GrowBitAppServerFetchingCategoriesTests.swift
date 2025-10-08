//
//  GrowBitAppServerFetchingCategoriesTests.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 08.10.25.
//

@testable import GrowBitAppServer
import VaporTesting
import GrowBitSharedDTO
import Testing
import Fluent

@Suite("Category Fetching Tests")
struct GrowBitAppServerFetchingCategoriesTests {

    @Test("Fetch all categories - Success with multiple categories")
    func fetchAllCategoriesSuccess() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "fetchuser1", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            // Retrieve the created user
            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "fetchuser1")
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

            for category in categories {
                try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                    try req.content.encode(category)
                } afterResponse: { res in
                    #expect(res.status == .ok)
                }
            }

            // Fetch all categories
            try await app.testing().test(.GET, "/api/\(userId.uuidString)/categories") { req in
                // No body needed for GET request
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode([CategoryResponseDTO].self)
                #expect(response.count == 3)

                // Verify category names
                let categoryNames = response.map { $0.name }
                #expect(categoryNames.contains("Work"))
                #expect(categoryNames.contains("Personal"))
                #expect(categoryNames.contains("Health"))

                // Verify all categories have valid IDs and color codes
                for category in response {
                    #expect(category.id != nil)
                    #expect(category.colorCode.hasPrefix("#"))
                }
            }
        }
    }

    @Test("Fetch all categories - Success with empty result")
    func fetchAllCategoriesEmptyResult() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "fetchuser2", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            // Retrieve the created user
            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "fetchuser2")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Fetch categories without creating any
            try await app.testing().test(.GET, "/api/\(userId.uuidString)/categories") { req in
                // No body needed for GET request
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode([CategoryResponseDTO].self)
                #expect(response.isEmpty)
            }
        }
    }

    @Test("Fetch all categories - Fail - Invalid userId")
    func fetchAllCategoriesInvalidUserId() async throws {
        try await withApp(configure: configure) { app in
            // Try to fetch categories with invalid UUID
            try await app.testing().test(.GET, "/api/invalid-uuid/categories") { req in
                // No body needed for GET request
            } afterResponse: { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Fetch all categories - User isolation test")
    func fetchAllCategoriesUserIsolation() async throws {
        try await withApp(configure: configure) { app in
            
            // Create two users
            
            let userRequestBody1 = User(username: "fetchuser3a", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody1)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            let userRequestBody2 = User(username: "fetchuser3b", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody2)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            // Retrieve the created users
            guard let createdUser1 = try await User.query(on: app.db)
                .filter(\.$username == "fetchuser3a")
                .first(),
                  let userId1 = createdUser1.id else {
                throw TestError.userCreationFailed
            }
            guard let createdUser2 = try await User.query(on: app.db)
                .filter(\.$username == "fetchuser3b")
                .first(),
                  let userId2 = createdUser2.id else {
                throw TestError.userCreationFailed
            }
            
            // Create categories for user1
            let categories1 = [
                ["name": "Work", "colorCode": "#FF0000"],
                ["name": "Personal", "colorCode": "#00FF00"],
                ["name": "Health", "colorCode": "#0000FF"]
            ]
            
            for category in categories1 {
                try await app.testing().test(.POST, "/api/\(userId1.uuidString)/categories") { req in
                    try req.content.encode(category)
                } afterResponse: { res in
                    #expect(res.status == .ok)
                }
            }
            
            // Create categories for user2
            
            let categories2 = [
                ["name": "Fitness", "colorCode": "#FFFF00"],
                ["name": "Hobbies", "colorCode": "#FF00FF"]
            ]
            
            for category in categories2 {
                try await app.testing().test(.POST, "/api/\(userId2.uuidString)/categories") { req in
                    try req.content.encode(category)
                } afterResponse: { res in
                    #expect(res.status == .ok)
                }
            }
            
            // Fetch categories for user1 and verify only user1's categories are returned
            
            try await app.testing().test(.GET, "/api/\(userId1.uuidString)/categories") { req in
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode([CategoryResponseDTO].self)
                #expect(response.count == 3)
                
                // Verify category names
                let categoryNames = response.map { $0.name }
                #expect(categoryNames.contains("Work"))
                #expect(categoryNames.contains("Personal"))
                #expect(categoryNames.contains("Health"))
                #expect(!categoryNames.contains("Fitness"))
            }
            
            // Fetch categories for user2 and verify only user2's categories are returned
            
            try await app.testing().test(.GET, "/api/\(userId2.uuidString)/categories") { req in
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode([CategoryResponseDTO].self)
                #expect(response.count == 2)
                
                // Verify category names
                let categoryNames = response.map { $0.name }
                #expect(!categoryNames.contains("Work"))
                #expect(!categoryNames.contains("Personal"))
                #expect(categoryNames.contains("Hobbies"))
                #expect(categoryNames.contains("Fitness"))
            }
        }

    }

    @Test("Fetch all categories - Verify color normalization persistence")
    func fetchAllCategoriesColorNormalization() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "fetchuser4", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            // Retrieve the created user
            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "fetchuser4")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Create categories with and without # prefix
            let categoriesWithColors = [
                ["name": "Cat1", "colorCode": "FF0000"],    // Without #
                ["name": "Cat2", "colorCode": "#00FF00"]    // With #
            ]

            for category in categoriesWithColors {
                try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                    try req.content.encode(category)
                } afterResponse: { res in
                    #expect(res.status == .ok)
                }
            }

            // Fetch all categories and verify normalization
            try await app.testing().test(.GET, "/api/\(userId.uuidString)/categories") { req in
                // No body needed for GET request
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode([CategoryResponseDTO].self)
                #expect(response.count == 2)

                // All color codes should have # prefix after normalization
                for category in response {
                    #expect(category.colorCode.hasPrefix("#"))
                    #expect(category.colorCode.count == 7) // # + 6 hex characters
                }
            }
        }
    }
}
