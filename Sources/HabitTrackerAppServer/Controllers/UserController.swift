//
//  UserController.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 24.09.25.
//

import Foundation
import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let api = routes.grouped("api")

        // /api/register
        api.post("register", use: register)
    }

    @Sendable func register(req: Request) async throws -> RegisterResponseDTO {
        try User.validate(content: req)
        
        let user = try req.content.decode(User.self)
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            return RegisterResponseDTO(error: true, reason: "Username is already taken")
        }
        
        // hash the password
        user.password = try await req.password.async.hash(user.password)
        
        // save the user into the database
        try await user.save(on: req.db)
        
        // find if the user exists
        return RegisterResponseDTO(error: false)
    }
}
