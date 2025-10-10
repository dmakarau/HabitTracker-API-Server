//
//  Item.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 10.10.25.
//

import Foundation
import Vapor
import Fluent
import GrowBitSharedDTO

enum Frequency: String, Codable, CaseIterable {
    case daily
    case weekly
    case monthly
}

extension Frequency: Sendable {
    init(from dto: FrequencyDTO) {
        self = Frequency(rawValue: dto.rawValue) ?? .daily
    }
    func toDTO() -> FrequencyDTO {
        FrequencyDTO(rawValue: self.rawValue)!
    }
}

final class Item: Model, Validatable, Content, Decodable, @unchecked Sendable {
    static let schema = "items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "start_date")
    var startDate: Date
    
    @Enum(key: "frequency")
    var frequency: Frequency
    
    @Field(key: "goal_days")
    var goalDays: Int
    
    @Field(key: "completed_days")
    var completedDays: Int
    
    @Field(key: "is_completed")
    var isCompleted: Bool
    
    @Parent(key: "category_id")
    var category: Category
    
    init() {}
    
    init(
        id: UUID? = nil,
        title: String,
        description: String? = nil,
        startDate: Date,
        frequency: Frequency,
        goalDays: Int,
        completedDays: Int = 0,
        isCompleted: Bool = false,
        categoryId: UUID
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.frequency = frequency
        self.goalDays = goalDays
        self.completedDays = completedDays
        self.isCompleted = isCompleted
        self.$category.id = categoryId
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty, customFailureDescription: "Title cannot be empty")
        validations.add("goal_days", as: Int.self, is: .range(1...), customFailureDescription: "Goal must be at least 1 day")
    }
}
