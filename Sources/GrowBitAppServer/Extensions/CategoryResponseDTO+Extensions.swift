//
//  CategoryResponseDTO+Extensions.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 06.10.25.
//

import Foundation
import GrowBitSharedDTO
import Vapor

extension CategoryResponseDTO: @retroactive RequestDecodable {}
extension CategoryResponseDTO: @retroactive ResponseEncodable {}
extension CategoryResponseDTO: @retroactive AsyncRequestDecodable {}
extension CategoryResponseDTO: @retroactive AsyncResponseEncodable {}
extension CategoryResponseDTO: @retroactive Content {
    init?(_ category: Category) {
        guard let id = category.id else { return nil }
        
        self.init(id: id, name: category.name, colorCode: category.colorCode)
    }
}
