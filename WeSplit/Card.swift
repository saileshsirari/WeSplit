//
//  Card.swift
//  WeSplit
//
//  Created by sailesh sirari on 22/10/24.
//

import SwiftUI

struct Card : Codable, Identifiable {
    var id  = UUID()
    var prompt: String
    var answer: String
    
    static let example = Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
    
}

#Preview {
    Card(prompt : Card.example.prompt, answer : Card.example.answer) as! any View
}
