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
    
    @Test("Item creation - Fail - Missing title")
    func testItemCreationFailWithMissingTitle() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_item_fail", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(RegisterResponseDTO.self)
                #expect(response.error == false)
            }
            
            // Retrieve the created user from the database
            guard let createdUserForItem = try await User.query(on: app.db)
                .filter(\.$username == "testuser_item_fail")
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
            
            // Now try to create an item without a title (should fail)
            let itemRequestBodyWithoutTitle = [
                "description": "Do 20 push-ups every day",
                "startDate": "2025-10-10T07:00:00Z",
                "frequency": "daily",
                "goalDays": "30",
                "categoryId": unwrappedCategoryId.uuidString
            ]
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBodyWithoutTitle)
                } afterResponse: { res in
                    // Should fail with bad request due to missing title
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Fail - Invalid user ID")
    func testItemCreationFailWithInvalidUserId() async throws {
        try await withApp(configure: configure) { app in
            let invalidUserId = "invalid-uuid"
            let categoryId = UUID()
            
            let itemRequestBody = ItemRequestDTO(
                title: "Test Item",
                description: "This is a test item",
                startDate: Date(),
                frequency: .daily,
                goalDays: 30,
                categoryId: categoryId
            )
            
            try await app.testing().test(
                .POST,
                "/api/\(invalidUserId)/categories/\(categoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBody)
                } afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Fail - Non-existent user")
    func testItemCreationFailWithNonExistentUser() async throws {
        try await withApp(configure: configure) { app in
            let nonExistentUserId = UUID()
            let categoryId = UUID()
            
            let itemRequestBody = ItemRequestDTO(
                title: "Test Item",
                description: "This is a test item",
                startDate: Date(),
                frequency: .daily,
                goalDays: 30,
                categoryId: categoryId
            )
            
            try await app.testing().test(
                .POST,
                "/api/\(nonExistentUserId.uuidString)/categories/\(categoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBody)
                } afterResponse: { res in
                    #expect(res.status == .notFound)
                }
        }
    }
    
    @Test("Item creation - Fail - Invalid category ID")
    func testItemCreationFailWithInvalidCategoryId() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_invalid_cat", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_invalid_cat")
                .first(),
                  let userId = user.id else {
                throw TestError.userCreationFailed
            }
            
            let invalidCategoryId = "invalid-uuid"
            let itemRequestBody = ItemRequestDTO(
                title: "Test Item",
                description: "This is a test item",
                startDate: Date(),
                frequency: .daily,
                goalDays: 30,
                categoryId: UUID()
            )
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(invalidCategoryId)/items") { req in
                    try req.content.encode(itemRequestBody)
                } afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Fail - Non-existent category")
    func testItemCreationFailWithNonExistentCategory() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_nonexist_cat", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_nonexist_cat")
                .first(),
                  let userId = user.id else {
                throw TestError.userCreationFailed
            }
            
            let nonExistentCategoryId = UUID()
            let itemRequestBody = ItemRequestDTO(
                title: "Test Item",
                description: "This is a test item",
                startDate: Date(),
                frequency: .daily,
                goalDays: 30,
                categoryId: nonExistentCategoryId
            )
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(nonExistentCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBody)
                } afterResponse: { res in
                    #expect(res.status == .notFound)
                }
        }
    }
    
    @Test("Item creation - Fail - Category belongs to different user")
    func testItemCreationFailWithUnauthorizedCategory() async throws {
        try await withApp(configure: configure) { app in
            // Create first user
            let user1RequestBody = User(username: "testuser1_auth", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(user1RequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Create second user
            let user2RequestBody = User(username: "testuser2_auth", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(user2RequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get both user IDs
            guard let user1 = try await User.query(on: app.db)
                .filter(\.$username == "testuser1_auth")
                .first(),
                  let user1Id = user1.id,
                  let user2 = try await User.query(on: app.db)
                .filter(\.$username == "testuser2_auth")
                .first(),
                  let user2Id = user2.id else {
                throw TestError.userCreationFailed
            }
            
            // Create a category for user1
            let categoryRequestBody = [
                "name": "User1 Category",
                "colorCode": "#FF0000"
            ]
            
            var user1CategoryId: UUID?
            try await app.testing().test(.POST, "/api/\(user1Id.uuidString)/categories") { req in
                try req.content.encode(categoryRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(CategoryResponseDTO.self)
                user1CategoryId = response.id
            }
            
            guard let categoryId = user1CategoryId else {
                throw TestError.userCreationFailed
            }
            
            // Try to create an item in user1's category using user2's ID (should fail)
            let itemRequestBody = ItemRequestDTO(
                title: "Test Item",
                description: "This is a test item",
                startDate: Date(),
                frequency: .daily,
                goalDays: 30,
                categoryId: categoryId
            )
            
            try await app.testing().test(
                .POST,
                "/api/\(user2Id.uuidString)/categories/\(categoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBody)
                } afterResponse: { res in
                    #expect(res.status == .notFound)
                }
        }
    }
    
    @Test("Item creation - Fail - Empty title")
    func testItemCreationFailWithEmptyTitle() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_empty_title", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_empty_title")
                .first(),
                  let userId = user.id else {
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
            
            // Try to create an item with empty title
            let itemRequestBodyWithEmptyTitle = [
                "title": "",
                "description": "This is a test item",
                "startDate": "2025-10-10T07:00:00Z",
                "frequency": "daily",
                "goalDays": "30",
                "categoryId": unwrappedCategoryId.uuidString
            ]
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBodyWithEmptyTitle)
                } afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Fail - Invalid frequency")
    func testItemCreationFailWithInvalidFrequency() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_invalid_freq", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_invalid_freq")
                .first(),
                  let userId = user.id else {
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
            
            // Try to create an item with invalid frequency
            let itemRequestBodyWithInvalidFreq = [
                "title": "Test Item",
                "description": "This is a test item",
                "startDate": "2025-10-10T07:00:00Z",
                "frequency": "invalid_frequency",
                "goalDays": "30",
                "categoryId": unwrappedCategoryId.uuidString
            ]
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBodyWithInvalidFreq)
                } afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Fail - Zero goal days")
    func testItemCreationFailWithZeroGoalDays() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_zero_goal", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_zero_goal")
                .first(),
                  let userId = user.id else {
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
            
            // Try to create an item with zero goal days
            let itemRequestBodyWithZeroGoal = [
                "title": "Test Item",
                "description": "This is a test item",
                "startDate": "2025-10-10T07:00:00Z",
                "frequency": "daily",
                "goalDays": "0",
                "categoryId": unwrappedCategoryId.uuidString
            ]
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBodyWithZeroGoal)
                } afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Fail - Negative goal days")
    func testItemCreationFailWithNegativeGoalDays() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_negative_goal", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_negative_goal")
                .first(),
                  let userId = user.id else {
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
            
            // Try to create an item with negative goal days
            let itemRequestBodyWithNegativeGoal = [
                "title": "Test Item",
                "description": "This is a test item",
                "startDate": "2025-10-10T07:00:00Z",
                "frequency": "daily",
                "goalDays": "-5",
                "categoryId": unwrappedCategoryId.uuidString
            ]
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBodyWithNegativeGoal)
                } afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Success - All frequency types")
    func testItemCreationSuccessWithDifferentFrequencies() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_frequencies", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_frequencies")
                .first(),
                  let userId = user.id else {
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
            
            // Test each frequency type
            let frequencies = ["daily", "weekly", "monthly"]
            
            for frequency in frequencies {
                let itemRequestBody = ItemRequestDTO(
                    title: "Test Item \(frequency)",
                    description: "This is a test item with \(frequency) frequency",
                    startDate: Date(),
                    frequency: FrequencyDTO(rawValue: frequency)!,
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
                        #expect(response.title == "Test Item \(frequency)")
                        #expect(response.frequency.rawValue == frequency)
                    }
            }
        }
    }
    
    @Test("Item creation - Fail - Invalid date format")
    func testItemCreationFailWithInvalidDate() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_invalid_date", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_invalid_date")
                .first(),
                  let userId = user.id else {
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
            
            // Try to create an item with invalid date format
            let itemRequestBodyWithInvalidDate = [
                "title": "Test Item",
                "description": "This is a test item",
                "startDate": "invalid-date-format",
                "frequency": "daily",
                "goalDays": "30",
                "categoryId": unwrappedCategoryId.uuidString
            ]
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBodyWithInvalidDate)
                } afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Fail - Invalid goalDays type")
    func testItemCreationFailWithInvalidGoalDaysType() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_invalid_goal_type", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_invalid_goal_type")
                .first(),
                  let userId = user.id else {
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
            
            // Try to create an item with invalid goalDays type
            let itemRequestBodyWithInvalidGoalType = [
                "title": "Test Item",
                "description": "This is a test item",
                "startDate": "2025-10-10T07:00:00Z",
                "frequency": "daily",
                "goalDays": "not-a-number",
                "categoryId": unwrappedCategoryId.uuidString
            ]
            
            try await app.testing().test(
                .POST,
                "/api/\(userId.uuidString)/categories/\(unwrappedCategoryId.uuidString)/items") { req in
                    try req.content.encode(itemRequestBodyWithInvalidGoalType)
                } afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
        }
    }
    
    @Test("Item creation - Success - Optional description field")
    func testItemCreationSuccessWithoutDescription() async throws {
        try await withApp(configure: configure) { app in
            // First create a user
            let userRequestBody = User(username: "testuser_no_desc", password: "password")
            try await app.testing().test(.POST, "/api/register") { req in
                try req.content.encode(userRequestBody)
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
            
            // Get the user ID
            guard let user = try await User.query(on: app.db)
                .filter(\.$username == "testuser_no_desc")
                .first(),
                  let userId = user.id else {
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
            
            // Create an item without description (should succeed)
            let itemRequestBody = ItemRequestDTO(
                title: "Test Item No Description",
                description: nil,
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
                    #expect(response.title == "Test Item No Description")
                    #expect(response.frequency == .daily)
                    #expect(response.goalDays == 30)
                }
        }
    }
}


