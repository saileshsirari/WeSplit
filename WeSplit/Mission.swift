//
//  Mission.swift
//  WeSplit
//
//  Created by sailesh sirari on 07/10/24.
//

import Foundation


struct Mission: Codable, Identifiable,Hashable {
   
    
    struct CrewRole: Codable,Hashable {
        let name: String
        let role: String
    }
    var displayName: String {
        "Apollo \(id)"
    }

    var image: String {
        "apollo\(id)"
    }
    let id: Int
    let launchDate: Date?
    var formattedLaunchDate: String {
        launchDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"
    }
    let crew: [CrewRole]
    let description: String
   
}
