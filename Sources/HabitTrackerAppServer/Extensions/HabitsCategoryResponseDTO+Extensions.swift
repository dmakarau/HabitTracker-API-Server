//
//  HabitsCategoryResponseDTO+Extensions.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 06.10.25.
//

import Foundation
import HabitTrackerAppSharedDTO
import Vapor

extension HabitsCategoryResponseDTO: @retroactive RequestDecodable {}
extension HabitsCategoryResponseDTO: @retroactive ResponseEncodable {}
extension HabitsCategoryResponseDTO: @retroactive AsyncRequestDecodable {}
extension HabitsCategoryResponseDTO: @retroactive AsyncResponseEncodable {}
extension HabitsCategoryResponseDTO: @retroactive Content {
    init?(_ category: Category) {
        guard let id = category.id else { return nil }
        
        self.init(id: id, name: category.name, colorCode: category.colorCode)
    }
}
