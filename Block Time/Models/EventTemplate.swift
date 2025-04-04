//
//  EventTemplate.swift
//  Block Time
//
//  Created by Julia Yu on 3/20/25.
//
import UIKit

struct EventTemplate {
    let id: UUID
    let title: String
    let duration: TimeInterval // in minutes
    let color: UIColor
    
    init(id: UUID = UUID(), title: String, duration: TimeInterval, color: UIColor) {
        self.id = id
        self.title = title
        self.duration = duration
        self.color = color
    }
    
    static func defaultTemplates() -> [EventTemplate] {
        return [
            EventTemplate(title: "Cooking", duration: 120, color: UIColor.systemOrange.withAlphaComponent(0.7)),
            EventTemplate(title: "Exercise", duration: 50, color: UIColor.systemGreen.withAlphaComponent(0.7)),
            EventTemplate(title: "Study", duration: 120, color: UIColor.systemBlue.withAlphaComponent(0.7)),
            EventTemplate(title: "Eat", duration: 30, color: UIColor.systemPurple.withAlphaComponent(0.7)),
            EventTemplate(title: "Break", duration: 50, color: UIColor.systemTeal.withAlphaComponent(0.7))
        ]
    }
}
