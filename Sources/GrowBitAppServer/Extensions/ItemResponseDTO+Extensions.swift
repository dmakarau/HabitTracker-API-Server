//
//  File.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 10.10.25.
//

import Foundation
import GrowBitSharedDTO
import Vapor

extension ItemResponseDTO: @retroactive RequestDecodable {}
extension ItemResponseDTO: @retroactive ResponseEncodable {}
extension ItemResponseDTO: @retroactive AsyncRequestDecodable {}
extension ItemResponseDTO: @retroactive AsyncResponseEncodable {}
extension ItemResponseDTO: @retroactive Content {
    init?(_ item: Item) {
        guard let id = item.id else { return nil }
        self.init(
            id: id,
            title: item.title,
            description: item.description,
            startDate: item.startDate,
            frequency: .init(from: item.frequency),
            goalDays: item.goalDays,
            completedDays: item.completedDays,
            isCompleted: item.isCompleted,
            categoryId: item.$category.id
        )
    }
}

extension FrequencyDTO {
    init(from frequency: Frequency) {
        self = FrequencyDTO(rawValue: frequency.rawValue)!
    }
}
            


