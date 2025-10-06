//
//  HabitTrackerAppServerSavingCategoryTests.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 06.10.25.
//

@testable import HabitTrackerAppServer
import VaporTesting
import HabitTrackerAppSharedDTO
import Testing
import Fluent

@Suite("Category Creation Tests")
struct HabitTrackerAppServerSavingCategoryTests {

    @Test("Category creation - Success")
    func categoryCreationSuccess() async throws {
        try await withApp(configure: configure) { app in
            // First create a user using the same pattern as other tests
            let userRequestBody = User(username: "testuser", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(RegisterResponseDTO.self)
                #expect(response.error == false)
            }

            // Retrieve the created user from the database
            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "testuser")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Create a simple request object with just name and colorCode (no id or userId)
            let requestBody = [
                "name": "test category",
                "colorCode": "#FFFFFF"
            ]

            try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(HabitsCategoryResponseDTO.self)
                #expect(response.name == "test category")
                #expect(response.colorCode == "#FFFFFF")
            }
        }
    }

    @Test("Category creation - Fail - Missing name")
    func categoryCreationFailMissingName() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "testuser2", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "testuser2")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Request body missing name
            let requestBody = [
                "colorCode": "#FFFFFF"
            ]

            try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .badRequest)
                #expect(res.body.string.contains("Missing required fields"))
            }
        }
    }

    @Test("Category creation - Fail - Missing colorCode")
    func categoryCreationFailMissingColorCode() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "testuser3", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "testuser3")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Request body missing colorCode
            let requestBody = [
                "name": "test category"
            ]

            try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .badRequest)
                #expect(res.body.string.contains("Missing required fields"))
            }
        }
    }

    @Test("Category creation - Fail - Invalid userId")
    func categoryCreationFailInvalidUserId() async throws {
        try await withApp(configure: configure) { app in
            let requestBody = [
                "name": "test category",
                "colorCode": "#FFFFFF"
            ]

            try await app.testing().test(.POST, "/api/invalid-uuid/categories") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Category creation - Fail - Empty name")
    func categoryCreationFailEmptyName() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "testuser4", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "testuser4")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Request body with empty name
            let requestBody = [
                "name": "",
                "colorCode": "#FFFFFF"
            ]

            try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Category creation - Fail - Invalid color code format")
    func categoryCreationFailInvalidColorCode() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "testuser5", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "testuser5")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Request body with invalid color code (missing #)
            let requestBody = [
                "name": "test category",
                "colorCode": "FFFFFF"
            ]

            try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Category creation - Success - Valid color codes")
    func categoryCreationSuccessVariousColors() async throws {
        try await withApp(configure: configure) { app in
            // Create a user
            let userRequestBody = User(username: "testuser6", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }

            guard let createdUser = try await User.query(on: app.db)
                .filter(\.$username == "testuser6")
                .first(),
                  let userId = createdUser.id else {
                throw TestError.userCreationFailed
            }

            // Test various valid color codes
            let validColors = ["#000000", "#FFFFFF", "#FF0000", "#00FF00", "#0000FF", "#abcdef", "#123456"]

            for (index, color) in validColors.enumerated() {
                let requestBody = [
                    "name": "category \(index)",
                    "colorCode": color
                ]

                try await app.testing().test(.POST, "/api/\(userId.uuidString)/categories") { req in
                    try req.content.encode(requestBody)
                } afterResponse: { res in
                    #expect(res.status == .ok)
                    let response = try res.content.decode(HabitsCategoryResponseDTO.self)
                    #expect(response.colorCode.uppercased() == color.uppercased())
                }
            }
        }
    }
}

enum TestError: Error {
    case userCreationFailed
}
