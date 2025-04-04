import UIKit
import EventKit

class CalendarExportManager {
    
    // MARK: - Properties
    weak var presentingViewController: UIViewController?
    private var events: [CalendarEvent]
    private var currentDate: Date
    private var googleCalendarManager: GoogleCalendarAPIManager?
    
    // MARK: - Initialization
    init(events: [CalendarEvent], currentDate: Date, presentingViewController: UIViewController) {
        self.events = events
        self.currentDate = currentDate
        self.presentingViewController = presentingViewController
    }
    
    // MARK: - Public Methods
    func showExportOptions(from barButtonItem: UIBarButtonItem? = nil) {
        let actionSheet = UIAlertController(
            title: "Export this day's events to",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let calendarOptions = [
            ("Apple Calendar", exportToAppleCalendar),
            ("Google Calendar", exportToGoogleCalendar)
        ]
        
        for (title, action) in calendarOptions {
            actionSheet.addAction(UIAlertAction(
                title: title,
                style: .default,
                handler: { [weak self] _ in
                    action()
                }
            ))
        }
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        
        if let popoverController = actionSheet.popoverPresentationController, let barItem = barButtonItem {
            popoverController.barButtonItem = barItem
        }
        
        presentingViewController?.present(actionSheet, animated: true)
    }
    
    // MARK: - Apple Calendar Export
    private func exportToAppleCalendar() {
        let eventStore = EKEventStore()
        
        let requestAccess: (@escaping (Bool, Error?) -> Void) -> Void = { completion in
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents(completion: completion)
            } else {
                eventStore.requestAccess(to: .event, completion: completion)
            }
        }
        
        requestAccess { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.addEventsToAppleCalendar(eventStore: eventStore)
                } else {
                    self?.showCalendarAccessDeniedAlert()
                }
            }
        }
    }
    
    internal func addEventsToAppleCalendar(eventStore: EKEventStore) {
        var successCount = 0
        var failureCount = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dateString = dateFormatter.string(from: currentDate)
        
        for calendarEvent in events {
            let event = EKEvent(eventStore: eventStore)
            event.title = calendarEvent.title
            
            let startDate = calendarEvent.startTime.combiningDateComponents(fromReferenceDate: currentDate)
            let endDate = calendarEvent.endTime.combiningDateComponents(
                fromReferenceDate: currentDate,
                isEndTime: true,
                startTime: calendarEvent.startTime
            )
            
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = eventStore.defaultCalendarForNewEvents
            event.notes = "Exported from Block Time for \(dateString)"
            
            do {
                try eventStore.save(event, span: .thisEvent)
                successCount += 1
            } catch {
                print("Error saving event to calendar: \(error)")
                failureCount += 1
            }
        }
        
        showExportResultAlert(successCount: successCount, failureCount: failureCount, service: "Apple Calendar")
    }
    
    // MARK: - Google Calendar Export
    internal func exportToGoogleCalendar() {
        guard let presentingViewController = presentingViewController else { return }
        
        googleCalendarManager = GoogleCalendarAPIManager(
            events: events,
            currentDate: currentDate,
            presentingViewController: presentingViewController
        )
        
        googleCalendarManager?.exportToGoogleCalendar { [weak self] successCount, failureCount in
            self?.showExportResultAlert(
                successCount: successCount,
                failureCount: failureCount,
                service: "Google Calendar"
            )
        }
    }
    
    // MARK: - Helper Methods
    private func showCalendarAccessDeniedAlert() {
        showAlert(
            title: "Calendar Access Denied",
            message: "Please enable calendar access in Settings to export events."
        )
    }
    
    internal func showExportResultAlert(successCount: Int, failureCount: Int, service: String) {
        let message: String
        
        if successCount > 0 && failureCount > 0 {
            message = "Successfully exported \(successCount) events to \(service). Failed to export \(failureCount) events."
        } else if successCount > 0 {
            message = "Successfully exported \(successCount) events to \(service)."
        } else {
            message = "Failed to export \(failureCount) events to \(service)."
        }
        
        showAlert(title: "Export Results", message: message)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        
        presentingViewController?.present(alertController, animated: true)
    }
}
