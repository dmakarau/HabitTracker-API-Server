//  Category.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 03.10.25.
//

import Foundation
import Fluent
import Vapor

final class Category: Model, Validatable, Content, @unchecked Sendable {
    static let schema = "categories"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "color_code")
    var colorCode: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, name: String, colorCode: String, userId: UUID) {
        self.id = id
        self.name = name
        self.colorCode = colorCode
        self.$user.id = userId
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty, customFailureDescription: "Category name cannot be empty")
        validations.add("colorCode", as: String.self, is: !.empty, customFailureDescription: "Color code cannot be empty")
        validations.add("color_code", as: String.self, is: .pattern(#"^#?([A-Fa-f0-9]{6})$"#), customFailureDescription: "Color code should be in format RRGGBB or #RRGGBB")
    }
    




    

    
}

