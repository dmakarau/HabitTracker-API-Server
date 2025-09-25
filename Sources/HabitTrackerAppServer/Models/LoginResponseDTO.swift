//
//  LoginResponseDTO.swift
//  HabitTrackerAppServer
//
//  Created by Denis Makarau on 25.09.25.
//

import Foundation
import Vapor

struct LoginResponseDTO: Content {
    
    let error: Bool
    var reeason: String?
    let token: String?
    let userId: UUID
    
}
