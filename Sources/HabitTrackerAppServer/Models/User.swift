//
//  User.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 24.09.25.
//

import Foundation
import Fluent
import Vapor

final class User: Model, Validatable, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
    
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("username", as: String.self, is: !.empty, customFailureDescription: "User name cannot be empty")
        validations.add("password", as: String.self, is: !.empty, customFailureDescription: "User's password cannot be empty")
        validations.add("password", as: String.self, is: .count(8...), customFailureDescription: "User's password should be at least 8 characters long")
    }
}
