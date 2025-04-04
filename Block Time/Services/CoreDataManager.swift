import CoreData
import UIKit

extension UIColor {
    func toRGBString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "\(red),\(green),\(blue),\(alpha)"
    }
    
    static func fromRGBString(_ string: String) -> UIColor {
        let components = string.split(separator: ",").compactMap { CGFloat(Double($0) ?? 0) }
        
        guard components.count == 4 else {
            return .systemBlue.withAlphaComponent(0.7)
        }
        
        return UIColor(
            red: components[0],
            green: components[1],
            blue: components[2],
            alpha: components[3]
        )
    }
}

class CoreDataManager {
    static var shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ScheduleModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Events CRUD
    
    func saveEvent(_ event: CalendarEvent) {
        saveEvent(event, for: Calendar.current.startOfDay(for: event.startTime))
    }
    
    func fetchEvent(withId id: UUID) -> CDCalendarEvent? {
        let fetchRequest: NSFetchRequest<CDCalendarEvent> = CDCalendarEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching event: \(error)")
            return nil
        }
    }
    
    func fetchAllEvents() -> [CalendarEvent] {
        let fetchRequest: NSFetchRequest<CDCalendarEvent> = CDCalendarEvent.fetchRequest()
        
        do {
            let cdEvents = try context.fetch(fetchRequest)
            return convertCDEventsToCalendarEvents(cdEvents)
        } catch {
            print("Error fetching events: \(error)")
            return []
        }
    }
    
    func deleteEvent(_ event: CalendarEvent) {
        if let cdEvent = fetchEvent(withId: event.id) {
            context.delete(cdEvent)
            saveContext()
        }
    }
    
    // MARK: - Templates CRUD
    
    func saveTemplate(_ template: EventTemplate) {
        if let existingTemplate = fetchTemplate(withId: template.id) {
            updateTemplate(existingTemplate, with: template)
        } else {
            createNewTemplate(template)
        }
        
        saveContext()
    }
    
    private func updateTemplate(_ cdTemplate: CDEventTemplate, with template: EventTemplate) {
        cdTemplate.title = template.title
        cdTemplate.duration = template.duration
        cdTemplate.colorRGB = template.color.toRGBString()
    }
    
    private func createNewTemplate(_ template: EventTemplate) {
        let cdTemplate = CDEventTemplate(context: context)
        cdTemplate.id = template.id
        cdTemplate.title = template.title
        cdTemplate.duration = template.duration
        cdTemplate.colorRGB = template.color.toRGBString()
    }
    
    func fetchTemplate(withId id: UUID) -> CDEventTemplate? {
        let fetchRequest: NSFetchRequest<CDEventTemplate> = CDEventTemplate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching template: \(error)")
            return nil
        }
    }
    
    func fetchAllTemplates() -> [EventTemplate] {
        let fetchRequest: NSFetchRequest<CDEventTemplate> = CDEventTemplate.fetchRequest()
        
        do {
            let cdTemplates = try context.fetch(fetchRequest)
            return cdTemplates.compactMap { cdTemplate in
                guard let id = cdTemplate.id,
                      let title = cdTemplate.title else {
                    return nil
                }
                
                let color = cdTemplate.colorRGB.map(UIColor.fromRGBString) ?? UIColor.systemBlue.withAlphaComponent(0.7)
                
                return EventTemplate(
                    id: id,
                    title: title,
                    duration: cdTemplate.duration,
                    color: color
                )
            }
        } catch {
            print("Error fetching templates: \(error)")
            return []
        }
    }
    
    func deleteTemplate(_ template: EventTemplate) {
        if let cdTemplate = fetchTemplate(withId: template.id) {
            context.delete(cdTemplate)
            saveContext()
        }
    }
    
    // MARK: - Days CRUD
    
    func fetchOrCreateDay(for date: Date) -> CDDay {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        if let existingDay = fetchDay(for: date) {
            return existingDay
        }
        
        let newDay = CDDay(context: context)
        newDay.id = UUID()
        newDay.date = startOfDay
        saveContext()
        
        return newDay
    }

    func fetchDay(for date: Date) -> CDDay? {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        let fetchRequest: NSFetchRequest<CDDay> = CDDay.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", dayStart as NSDate, dayEnd as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching day: \(error)")
            return nil
        }
    }

    func fetchAllEvents(for date: Date) -> [CalendarEvent] {
        guard let day = fetchDay(for: date),
              let cdEvents = day.events?.allObjects as? [CDCalendarEvent] else {
            return []
        }
        
        return convertCDEventsToCalendarEvents(cdEvents)
    }
    
    private func convertCDEventsToCalendarEvents(_ cdEvents: [CDCalendarEvent]) -> [CalendarEvent] {
        return cdEvents.compactMap { cdEvent in
            guard let id = cdEvent.id,
                  let title = cdEvent.title,
                  let startTime = cdEvent.startTime,
                  let endTime = cdEvent.endTime else {
                return nil
            }
            
            let color = cdEvent.colorRGB.map(UIColor.fromRGBString) ?? UIColor.systemBlue.withAlphaComponent(0.7)
            
            return CalendarEvent(
                id: id,
                title: title,
                startTime: startTime,
                endTime: endTime,
                color: color
            )
        }
    }

    func saveEvent(_ event: CalendarEvent, for date: Date) {
        let cdDay = fetchOrCreateDay(for: date)
        
        if let existingEvent = fetchEvent(withId: event.id) {
            updateEvent(existingEvent, with: event, day: cdDay)
        } else {
            createNewEvent(event, day: cdDay)
        }
        
        saveContext()
    }
    
    private func updateEvent(_ cdEvent: CDCalendarEvent, with event: CalendarEvent, day: CDDay) {
        cdEvent.title = event.title
        cdEvent.startTime = event.startTime
        cdEvent.endTime = event.endTime
        cdEvent.colorRGB = event.color.toRGBString()
        cdEvent.day = day
    }
    
    private func createNewEvent(_ event: CalendarEvent, day: CDDay) {
        let cdEvent = CDCalendarEvent(context: context)
        cdEvent.id = event.id
        cdEvent.title = event.title
        cdEvent.startTime = event.startTime
        cdEvent.endTime = event.endTime
        cdEvent.colorRGB = event.color.toRGBString()
        cdEvent.day = day
    }
}
