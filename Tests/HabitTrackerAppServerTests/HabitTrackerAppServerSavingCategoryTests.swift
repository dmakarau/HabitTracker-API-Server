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
}

enum TestError: Error {
    case userCreationFailed
}
