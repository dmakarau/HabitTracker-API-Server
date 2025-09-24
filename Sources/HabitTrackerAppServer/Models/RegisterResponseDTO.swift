//
//  RegisterResponseDTO.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 24.09.25.
//

import Foundation
import Vapor

struct RegisterResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
}
