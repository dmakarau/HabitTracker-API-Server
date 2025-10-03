//
//  UserController.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 24.09.25.
//

import Foundation
import Vapor
import Fluent
import HabitTrackerAppSharedDTO

struct UserController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let api = routes.grouped("api")

        // /api/register
        api.post("register", use: register)
        
        // /api/login
        api.post("login", use: login)
    }
    
    @Sendable func login(req: Request) async throws ->  LoginResponseDTO {
        
        // decode the request
        let user = try req.content.decode(User.self)
        
        // check if the user is in DB
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() else {
                throw Abort(.badRequest, reason: "User not found")
            }
        
        // check the password
        let result = try await req.password.async.verify(user.password, created: existingUser.password)
        if !result {
            throw Abort(.unauthorized, reason: "Wrong password")
        }
        
        // generate the token and return it to the user
        let authPayload = try AuthPayload(
            expiration: .init(value: .distantFuture),
            userId: existingUser.requireID()
        )
        return try await LoginResponseDTO(error: false, token: req.jwt.sign(authPayload), userId: existingUser.requireID())
    }

    @Sendable func register(req: Request) async throws -> RegisterResponseDTO {
        do {
            try User.validate(content: req)
        } catch let error as ValidationsError {
            // 422 Unprocessable Entity for validation failures
            throw Abort(.unprocessableEntity, reason: error.description)
        }

        let user = try req.content.decode(User.self)
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            // 409 Conflict for username already taken
            throw Abort(.conflict, reason: "Username is already taken")
        }
        
        // hash the password
        user.password = try await req.password.async.hash(user.password)
        
        // save the user into the database
        try await user.save(on: req.db)
        
        // find if the user exists
        return RegisterResponseDTO(error: false)
    }
}
