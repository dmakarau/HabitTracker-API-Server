//
//  RegisterResponseDTO.swift
//  GrowBitAppServer
//
//  Created by Denis Makarau on 03.10.25.
//

import Foundation
import Vapor
import GrowBitSharedDTO

extension RegisterResponseDTO: @retroactive RequestDecodable {}
extension RegisterResponseDTO: @retroactive ResponseEncodable {}
extension RegisterResponseDTO: @retroactive AsyncRequestDecodable {}
extension RegisterResponseDTO: @retroactive AsyncResponseEncodable {}
extension RegisterResponseDTO: @retroactive Content {}
