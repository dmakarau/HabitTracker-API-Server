//
//  RegisterResponseDTO.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 03.10.25.
//

import Foundation
import HabitTrackerAppSharedDTO
import Vapor

extension LoginResponseDTO: @retroactive RequestDecodable {}
extension LoginResponseDTO: @retroactive ResponseEncodable {}
extension LoginResponseDTO: @retroactive AsyncRequestDecodable {}
extension LoginResponseDTO: @retroactive AsyncResponseEncodable {}
extension LoginResponseDTO: @retroactive Content {}
