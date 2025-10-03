@testable import HabitTrackerAppServer
import VaporTesting
import HabitTrackerAppSharedDTO
import Testing

@Suite("App Registration Tests")
struct HabitTrackerAppServerRegistrationTests {
    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }
    
    @Test("User Registration - Success")
    func userRegistrationSuccess() async throws {
        try await withApp(configure: configure) { app in
            let requestBody = User(username: UUID().uuidString, password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(RegisterResponseDTO.self)
                #expect(response.error == false)
            }
        }
    }
    
    @Test("User Registration - Fail - Weak password")
    func userRegistrationFailWeakPassword() async throws {
        try await withApp(configure: configure) { app in
            let requestBody = User(username: UUID().uuidString, password: "p")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .unprocessableEntity) // 422
                #expect(res.body.string.contains("password"))
            }
        }
    }
    
    @Test("User Registration - Fail - User exists")
    func userRegistrationFailExistingUser() async throws {
        try await withApp(configure: configure) { app in
            // First registration - should succeed
            let requestBody = User(username: "existingUser", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(requestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(RegisterResponseDTO.self)
                #expect(response.error == false)
            }
            // Try to register with the same useername
            let requestBodyExistingUser = User(username: "existingUser", password: "newpassword")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(requestBodyExistingUser)
            } afterResponse: { res in
                #expect(res.status == .conflict) // 409
                #expect(res.body.string.contains("Username"))
            }
        }
    }
}
