import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import SafariServices

class GoogleCalendarAPIManager {
    
    // MARK: - Properties
    private let calendarService = GTLRCalendarService()
    private weak var presentingViewController: UIViewController?
    private var events: [CalendarEvent]
    private var currentDate: Date
    private let invalidTokenError = "invalid_grant: Token has been expired or revoked."
    
    private var completionHandler: ((Int, Int) -> Void)?
    
    // MARK: - Initialization
    init(events: [CalendarEvent], currentDate: Date, presentingViewController: UIViewController) {
        self.events = events
        self.currentDate = currentDate
        self.presentingViewController = presentingViewController
    }
    
    // MARK: - Google Calendar Export
    func exportToGoogleCalendar(completion: @escaping (Int, Int) -> Void) {
        self.completionHandler = completion
        signInToGoogle()
    }

    private func signInToGoogle() {
        guard let presentingViewController = presentingViewController else { return }
        
        let additionalScopes = ["https://www.googleapis.com/auth/calendar"]
        
        if let currentUser = GIDSignIn.sharedInstance.currentUser,
           let grantedScopes = currentUser.grantedScopes,
           grantedScopes.contains(additionalScopes[0]) {
            self.handleSignInSuccess(user: currentUser)
            return
        }
        
        DispatchQueue.main.async {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: additionalScopes
            ) { [weak self] signInResult, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error signing in: \(error.localizedDescription)")
                        self.showAlert(
                            title: "Sign-In Failed",
                            message: "Unable to sign in to Google: \(error.localizedDescription)"
                        )
                        self.completionHandler?(0, self.events.count)
                        return
                    }
                    
                    guard let signInResult = signInResult else { return }
                    self.handleSignInSuccess(user: signInResult.user)
                }
            }
        }
    }
    
    private func handleSignInSuccess(user: GIDGoogleUser) {
        calendarService.authorizer = user.fetcherAuthorizer
        
        if events.isEmpty {
            showAlert(title: "No Events", message: "There are no events to export.")
            completionHandler?(0, 0)
        } else {
            exportAllEvents()
        }
    }

    private func addEventToGoogleCalendar(event: CalendarEvent, completion: ((Bool) -> Void)? = nil) {
        let calendarEvent = GTLRCalendar_Event()
        calendarEvent.summary = event.title
        
        let eventStartDate = event.startTime.combiningDateComponents(fromReferenceDate: currentDate)
        let eventEndDate = event.endTime.combiningDateComponents(
            fromReferenceDate: currentDate,
            isEndTime: true,
            startTime: event.startTime
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone.current
        
        let startTimeString = dateFormatter.string(from: eventStartDate)
        let endTimeString = dateFormatter.string(from: eventEndDate)
        
        let startDateTime = GTLRCalendar_EventDateTime()
        startDateTime.dateTime = GTLRDateTime(rfc3339String: startTimeString)
        startDateTime.timeZone = TimeZone.current.identifier
        calendarEvent.start = startDateTime
        
        let endDateTime = GTLRCalendar_EventDateTime()
        endDateTime.dateTime = GTLRDateTime(rfc3339String: endTimeString)
        endDateTime.timeZone = TimeZone.current.identifier
        calendarEvent.end = endDateTime
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "EEEE, MMMM d, yyyy"
        let dateString = dateFormatter2.string(from: currentDate)
        calendarEvent.descriptionProperty = "Exported from Block Time for \(dateString)"
        
        let query = GTLRCalendarQuery_EventsInsert.query(withObject: calendarEvent, calendarId: "primary")
        
        calendarService.executeQuery(query) { [weak self] (_, _, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    if error.localizedDescription == self.invalidTokenError {
                        print("Error signing in: \(error.localizedDescription)")
                        self.showAlert(
                            title: "Sign-In Failed",
                            message: "Token was invalidated due to cancelled connection. Please retry exporting to sign in again."
                        )
                    } else {
                        print("Error adding event to Google Calendar: \(error.localizedDescription)")
                    }
                    GIDSignIn.sharedInstance.signOut()
                    completion?(false)
                    return
                }
                
                completion?(true)
            }
        }
    }

    private func exportAllEvents() {
        var successCount = 0
        var failureCount = 0
        let group = DispatchGroup()
        
        for event in events {
            group.enter()
            addEventToGoogleCalendar(event: event) { success in
                if success {
                    successCount += 1
                } else {
                    failureCount += 1
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.completionHandler?(successCount, failureCount)
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        guard let presentingViewController = presentingViewController else { return }
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        
        presentingViewController.present(alertController, animated: true)
    }
}
