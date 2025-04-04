//
//  CalendarEvent.swift
//  Block Time
//
//  Created by Julia Yu on 3/20/25.
//
import UIKit

struct CalendarEvent {
    var id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var color: UIColor
    
    init(id: UUID = UUID(), title: String, startTime: Date, endTime: Date, color: UIColor) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
    }
}
