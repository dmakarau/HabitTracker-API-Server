//
//  HabitTrackerAppServerLoginTests.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 26.09.25.
//

import Foundation
@testable import HabitTrackerAppServer
import HabitTrackerAppSharedDTO
import VaporTesting
import Testing

@Suite("App Login Tests")
struct HabitTrackerAppServerLoginTests {
    
    private func createUser(in app: Application, username: String = "testuser") async throws {
        let requestBody = User(username: username, password: "password")
        try await app.testing().test(.POST, "/api/register") { req in
            try req.content.encode(requestBody)
        } afterResponse: { res in
            #expect(res.status == .ok)
            let response = try res.content.decode(RegisterResponseDTO.self)
            #expect(response.error == false)
        }
    }
    @Test("Test User Login Success")
    func testUserLoginSuccess() async throws {
        try await withApp(configure: configure) { app in
            // Create user in this app instance
            try await createUser(in: app)

            // Now test login with the same app instance
            let loginCredentials = User(username: "testuser", password: "password")
            try await app.testing().test(.POST, "/api/login") { req in
                try req.content.encode(loginCredentials)
            } afterResponse: { res in
                #expect(res.status == .ok)

                let response = try res.content.decode(LoginResponseDTO.self)
                #expect(response.error == false)
                #expect(response.token != nil)
                #expect(response.reason == nil) // Should be nil on success
            }
        }
    }
    
    @Test("Test User Login Fail - Wrong username")
    func testUserLoginFailureWrongUsername() async throws {
        try await withApp(configure: configure) { app in
            // Create user in this app instance
            try await createUser(in: app)

            // Now test login with the same app instance
            let loginCredentials = User(username: "wronguser", password: "password")
            try await app.testing().test(.POST, "/api/login") { req in
                try req.content.encode(loginCredentials)
            } afterResponse: { res in
                #expect(res.status == .badRequest)
                // Check that we get a meaningful error response (not empty)
                #expect(!res.body.string.isEmpty)
                #expect(res.body.string.contains("User not found"))

            }
        }
    }
    
    @Test("Test User Login Fail - Wrong password")
    func testUserLoginFailureWrongPassword() async throws {
        try await withApp(configure: configure) { app in
            // Create user in this app instance
            try await createUser(in: app)

            // Now test login with the same app instance
            let loginCredentials = User(username: "testuser", password: "wrongpassword")
            try await app.testing().test(.POST, "/api/login") { req in
                try req.content.encode(loginCredentials)
            } afterResponse: { res in
                #expect(res.status == .unauthorized)
                // Check that we get a meaningful error response (not empty)
                #expect(!res.body.string.isEmpty)
                #expect(res.body.string.contains("Wrong password"))

            }
        }
    }
    
    @Test("Test User Login Fail - Wrong username and wrong password")
    func testUserLoginFailureWrongUsernameAndWrongPassword() async throws {
        try await withApp(configure: configure) { app in
            // Create user in this app instance
            try await createUser(in: app)

            // Now test login with the same app instance
            let loginCredentials = User(username: "wronguser", password: "wrongpassword")
            try await app.testing().test(.POST, "/api/login") { req in
                try req.content.encode(loginCredentials)
            } afterResponse: { res in
                #expect(res.status == .badRequest)
                // Check that we get a meaningful error response (not empty)
                #expect(!res.body.string.isEmpty)
                #expect(res.body.string.contains("User not found"))

            }
        }
    }
}


