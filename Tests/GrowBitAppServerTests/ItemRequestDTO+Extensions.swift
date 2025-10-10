//
//  ItemRequestDTO+Extensions.swift
//  GrowBitAppServer
//
//  Created by Assistant on 10.10.25.
//

import Foundation
import GrowBitSharedDTO
import Vapor

extension ItemRequestDTO: @retroactive RequestDecodable {}
extension ItemRequestDTO: @retroactive ResponseEncodable {}
extension ItemRequestDTO: @retroactive AsyncRequestDecodable {}
extension ItemRequestDTO: @retroactive AsyncResponseEncodable {}
extension ItemRequestDTO: @retroactive Content {}
