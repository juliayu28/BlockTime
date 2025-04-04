import UIKit

class CalendarDayViewController: UIViewController, UIGestureRecognizerDelegate, AddTemplateViewControllerDelegate, AIScheduleViewControllerDelegate, EditEventViewControllerDelegate {
    
    // MARK: - Properties
    internal var calendarDayView: CalendarDayView!
    var events: [CalendarEvent] = []
    var eventViews: [UUID: EventView] = [:]
    private var activeEventView: EventView?
    internal var eventTemplates: [EventTemplate] = []
    private var draggedTemplate: EventTemplateView?
    private var draggedEventPreview: UIView?
    private var isTemplateBeingDragged = false
    var isDeleteModeActive = false
    private var exportButton: UIBarButtonItem!
    var currentDate: Date
    
    private var calendarExportManager: CalendarExportManager?
    
    init(date: Date = Date()) {
        self.currentDate = Calendar.current.startOfDay(for: date)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.currentDate = Calendar.current.startOfDay(for: Date())
        super.init(coder: coder)
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Daily Schedule"
        view.backgroundColor = .systemBackground
        
        setupCalendarDayView()
        
        loadEventsForCurrentDay()
        loadTemplates()
        
        setupNavigationBar()
        setupCalendarComponents()
        setupEvents()
    }
    
    private func setupCalendarDayView() {
        calendarDayView = CalendarDayView(frame: view.bounds)
        calendarDayView.dayViewWidth = view.bounds.width - calendarDayView.timeColumnWidth
        view.addSubview(calendarDayView)
        
        calendarDayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarDayView.topAnchor.constraint(equalTo: view.topAnchor),
            calendarDayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarDayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarDayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCalendarComponents() {
        calendarDayView.setupScrollView()
        calendarDayView.setupTimelineView()
        calendarDayView.setupHourLabels()
        calendarDayView.setupCurrentTimeIndicator()
        calendarDayView.setupEventContainerView()
        calendarDayView.setupTemplateHeader()
        calendarDayView.setupTemplateScrollView()
        
        // Connect button actions
        if let addTemplateButton = calendarDayView.templateContainerView.viewWithTag(100) as? UIButton {
            addTemplateButton.addTarget(self, action: #selector(showAddTemplateScreen), for: .touchUpInside)
        }
        
        if let aiScheduleButton = calendarDayView.templateContainerView.viewWithTag(101) as? UIButton {
            aiScheduleButton.addTarget(self, action: #selector(showAIScheduleGenerator), for: .touchUpInside)
        }
        
        if let deleteButton = calendarDayView.templateContainerView.viewWithTag(102) as? UIButton {
            deleteButton.addTarget(self, action: #selector(toggleDeleteMode), for: .touchUpInside)
        }
        
        calendarDayView.scrollToCurrentTime()
        addTemplateItemsToStackView()
    }
    
    private func loadEventsForCurrentDay() {
        events = CoreDataManager.shared.fetchAllEvents(for: currentDate)
    }
    
    private func loadTemplates() {
        eventTemplates = CoreDataManager.shared.fetchAllTemplates()
        
        if eventTemplates.isEmpty {
            eventTemplates = EventTemplate.defaultTemplates()
            for template in eventTemplates {
                CoreDataManager.shared.saveTemplate(template)
            }
        }
    }
    
    func changeDay(to date: Date) {
        currentDate = Calendar.current.startOfDay(for: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        updateDayTitle(with: dateFormatter.string(from: currentDate))
        
        clearExistingEvents()
        loadEventsForCurrentDay()
        setupEvents()
    }
    
    private func clearExistingEvents() {
        for eventView in eventViews.values {
            eventView.removeFromSuperview()
        }
        eventViews.removeAll()
        events.removeAll()
    }
    
    private func updateDayTitle(with text: String) {
        calendarDayView.dayTitleLabel.text = text
    }
    
    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        exportButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(showExportOptions)
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        
        calendarDayView.dayTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 44))
        calendarDayView.dayTitleLabel.text = dateFormatter.string(from: currentDate)
        calendarDayView.dayTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        calendarDayView.dayTitleLabel.textColor = .systemBlue
        calendarDayView.dayTitleLabel.textAlignment = .center
        calendarDayView.dayTitleLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToDate))
        calendarDayView.dayTitleLabel.addGestureRecognizer(tapGesture)
        
        let dateTitleItem = UIBarButtonItem(customView: calendarDayView.dayTitleLabel)
        
        let prevDayButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(showPreviousDay)
        )
        
        let nextDayButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"),
            style: .plain,
            target: self,
            action: #selector(showNextDay)
        )
        
        let balanceSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        balanceSpace.width = 15
        
        navigationItem.setLeftBarButtonItems([exportButton, balanceSpace], animated: false)
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addNewEvent)
            )
        ], animated: false)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 15
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 280, height: 45))
        toolbar.items = [prevDayButton, fixedSpace, dateTitleItem, fixedSpace, nextDayButton]
        toolbar.barTintColor = .clear
        toolbar.backgroundColor = .clear
        toolbar.isTranslucent = true
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        toolbar.sizeToFit()
        navigationItem.titleView = toolbar
    }
    
    @objc private func showExportOptions() {
        calendarExportManager = CalendarExportManager(
            events: events,
            currentDate: currentDate,
            presentingViewController: self
        )
        calendarExportManager?.showExportOptions(from: exportButton)
    }
    
    @objc internal func showPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            changeDay(to: previousDay)
        }
    }
    
    @objc internal func showNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            changeDay(to: nextDay)
        }
    }
    
    @objc private func goToDate() {
        let alert = UIAlertController(title: "Go to Date", message: nil, preferredStyle: .alert)
        
        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        alert.view.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = currentDate
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            datePicker.leftAnchor.constraint(equalTo: alert.view.leftAnchor, constant: 20),
            datePicker.rightAnchor.constraint(equalTo: alert.view.rightAnchor, constant: -20)
        ])
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Go", style: .default) { [weak self] _ in
            self?.changeDay(to: datePicker.date)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Events Setup
    private func setupEvents() {
        for event in events {
            addEventToView(event)
        }
    }
    
    internal func addEventToView(_ event: CalendarEvent) {
        let eventView = EventView(event: event)
        calendarDayView.eventContainerView.addSubview(eventView)
        
        let startY = calendarDayView.timeToPosition(event: event.startTime)
        let endY = calendarDayView.timeToPosition(event: event.endTime)
        let height = endY - startY
        
        eventView.frame = CGRect(
            x: 8,
            y: startY,
            width: calendarDayView.dayViewWidth - 16,
            height: height
        )
        
        eventViews[event.id] = eventView
        
        setupEventGestures(eventView)
    }
    
    private func setupEventGestures(_ eventView: EventView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        eventView.addGestureRecognizer(tapGesture)
        
        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMove))
        eventView.contentView.addGestureRecognizer(moveGesture)
        
        let topResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTopResize))
        eventView.topHandleView.addGestureRecognizer(topResizeGesture)
        
        let bottomResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleBottomResize))
        eventView.bottomHandleView.addGestureRecognizer(bottomResizeGesture)
    }
    
    internal func createEventFromTemplate(_ template: EventTemplate, startTime: Date) {
        let calendar = Calendar.current
        let endTime = calendar.date(byAdding: .minute, value: Int(template.duration), to: startTime) ?? startTime
        
        let newEvent = CalendarEvent(
            title: template.title,
            startTime: startTime,
            endTime: endTime,
            color: template.color
        )
        
        events.append(newEvent)
        addEventToView(newEvent)
        
        CoreDataManager.shared.saveEvent(newEvent, for: currentDate)
    }
    
    private func addTemplateItemsToStackView() {
        calendarDayView.templateStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let templateWidth: CGFloat = 100
        
        for template in eventTemplates {
            let templateView = EventTemplateView(template: template)
            calendarDayView.templateStackView.addArrangedSubview(templateView)
            
            templateView.widthAnchor.constraint(equalToConstant: templateWidth).isActive = true
            templateView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            if isDeleteModeActive {
                let deleteOverlay = calendarDayView.createDeleteOverlay()
                templateView.addSubview(deleteOverlay)
                
                deleteOverlay.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    deleteOverlay.topAnchor.constraint(equalTo: templateView.topAnchor),
                    deleteOverlay.leadingAnchor.constraint(equalTo: templateView.leadingAnchor),
                    deleteOverlay.trailingAnchor.constraint(equalTo: templateView.trailingAnchor),
                    deleteOverlay.bottomAnchor.constraint(equalTo: templateView.bottomAnchor)
                ])
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTemplateDeleteTap(_:)))
                templateView.gestureRecognizers?.forEach { templateView.removeGestureRecognizer($0) }
                templateView.addGestureRecognizer(tapGesture)
            } else {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTemplateLongPress))
                longPressGesture.minimumPressDuration = 0.2
                
                templateView.gestureRecognizers?.forEach { templateView.removeGestureRecognizer($0) }
                templateView.addGestureRecognizer(longPressGesture)
            }
            
            templateView.isUserInteractionEnabled = true
        }
        
        calendarDayView.updateTemplateScrollViewContentSize(templateWidth: templateWidth, templateCount: eventTemplates.count)
    }
    
    // MARK: - Event Handlers
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let eventView = gesture.view as? EventView else { return }
        editEvent(eventView.event)
    }
    
    @objc private func handleMove(_ gesture: UIPanGestureRecognizer) {
        guard let contentView = gesture.view,
              let eventView = contentView.superview as? EventView else { return }
        
        let translation = gesture.translation(in: calendarDayView.eventContainerView)
        
        switch gesture.state {
        case .began:
            self.activeEventView = eventView
            
        case .changed:
            let newY = eventView.frame.origin.y + translation.y
            
            if newY >= 0 && (newY + eventView.frame.height) <= self.calendarDayView.contentView.bounds.height {
                eventView.frame = CGRect(
                    x: eventView.frame.origin.x,
                    y: newY,
                    width: eventView.frame.width,
                    height: eventView.frame.height
                )
            }
            
            gesture.setTranslation(.zero, in: calendarDayView.eventContainerView)
            
        case .ended, .cancelled:
            updateEventTimes(eventView: eventView)
            self.activeEventView = nil
            
        default:
            break
        }
    }
    
    @objc private func handleTopResize(_ gesture: UIPanGestureRecognizer) {
        guard let handleView = gesture.view,
              let eventView = handleView.superview as? EventView else { return }
        
        let translation = gesture.translation(in: calendarDayView.eventContainerView)
        
        switch gesture.state {
        case .began:
            self.activeEventView = eventView
            
        case .changed:
            let newY = eventView.frame.origin.y + translation.y
            let newHeight = eventView.frame.height - translation.y
            
            if newY >= 0 && newY < self.calendarDayView.contentView.bounds.height && newHeight >= 30 {
                eventView.frame = CGRect(
                    x: eventView.frame.origin.x,
                    y: newY,
                    width: eventView.frame.width,
                    height: newHeight
                )
            }
            
            gesture.setTranslation(.zero, in: calendarDayView.eventContainerView)
            
        case .ended, .cancelled:
            updateEventTimes(eventView: eventView)
            self.activeEventView = nil
            
        default:
            break
        }
    }
    
    @objc private func handleBottomResize(_ gesture: UIPanGestureRecognizer) {
        guard let handleView = gesture.view,
              let eventView = handleView.superview as? EventView else { return }
        
        let translation = gesture.translation(in: calendarDayView.eventContainerView)
        
        switch gesture.state {
        case .began:
            self.activeEventView = eventView
            
        case .changed:
            let newHeight = eventView.frame.height + translation.y
            let newBottomY = eventView.frame.origin.y + newHeight
            
            if newHeight >= 30 && newBottomY <= self.calendarDayView.contentView.bounds.height {
                eventView.frame = CGRect(
                    x: eventView.frame.origin.x,
                    y: eventView.frame.origin.y,
                    width: eventView.frame.width,
                    height: newHeight
                )
            }
            
            gesture.setTranslation(.zero, in: calendarDayView.eventContainerView)
            
        case .ended, .cancelled:
            updateEventTimes(eventView: eventView)
            self.activeEventView = nil
            
        default:
            break
        }
    }
    
    private func updateEventTimes(eventView: EventView) {
        let startY = max(0, min(self.calendarDayView.contentView.bounds.height, eventView.frame.origin.y))
        let endY = max(startY + 15, min(self.calendarDayView.contentView.bounds.height, startY + eventView.frame.height))
        
        let isAtBottom = endY >= calendarDayView.contentView.bounds.height - 5
        
        let startTime = calendarDayView.positionToTime(position: startY, roundToMinutes: 5)
        var endTime = calendarDayView.positionToTime(position: endY, roundToMinutes: 5)
        
        if isAtBottom {
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) ?? Date()
            endTime = tomorrow
        }
        
        guard let index = events.firstIndex(where: { $0.id == eventView.event.id }) else { return }
        events[index].startTime = startTime
        events[index].endTime = endTime
        
        eventView.event = events[index]
        eventView.updateUI()
        
        let roundedStartY = calendarDayView.timeToPosition(event: startTime)
        let roundedEndY = calendarDayView.timeToPosition(event: endTime)
        let height = roundedEndY - roundedStartY
        
        eventView.frame = CGRect(
            x: eventView.frame.origin.x,
            y: roundedStartY,
            width: eventView.frame.width,
            height: height
        )
        
        CoreDataManager.shared.saveEvent(events[index], for: currentDate)
    }
    
    // MARK: - Template Event Handlers
    @objc func handleTemplateLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let templateView = gesture.view as? EventTemplateView else { return }
        
        switch gesture.state {
        case .began:
            isTemplateBeingDragged = true
            draggedTemplate = templateView
            
            let previewView = UIView()
            previewView.backgroundColor = templateView.template.color
            previewView.layer.cornerRadius = 8
            previewView.alpha = 0.7
            
            let durationInHours = templateView.template.duration / 60
            let height = CGFloat(durationInHours) * calendarDayView.hourHeight
            
            let templateFrame = templateView.convert(templateView.bounds, to: view)
            previewView.frame = CGRect(
                x: calendarDayView.timeColumnWidth + 8,
                y: templateFrame.midY - (height / 2),
                width: calendarDayView.dayViewWidth - 16,
                height: height
            )
            
            view.addSubview(previewView)
            draggedEventPreview = previewView
            
            UIView.animate(withDuration: 0.2) {
                templateView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                templateView.alpha = 0.7
            }
            
        case .changed:
            guard let previewView = draggedEventPreview else { return }
            
            let touchPoint = gesture.location(in: view)
            
            let durationInHours = templateView.template.duration / 60
            let height = CGFloat(durationInHours) * calendarDayView.hourHeight
            
            previewView.frame = CGRect(
                x: calendarDayView.timeColumnWidth + 8,
                y: touchPoint.y - (height / 2),
                width: calendarDayView.dayViewWidth - 16,
                height: height
            )
            
        case .ended, .cancelled:
            isTemplateBeingDragged = false
            
            guard let templateView = draggedTemplate,
                  let previewView = draggedEventPreview else { return }
            
            UIView.animate(withDuration: 0.2) {
                templateView.transform = .identity
                templateView.alpha = 1.0
            }
            
            let touchPoint = gesture.location(in: view)
            let scrollViewPoint = calendarDayView.scrollView.convert(touchPoint, from: view)
            let contentPoint = calendarDayView.contentView.convert(scrollViewPoint, from: calendarDayView.scrollView)
                    
            if contentPoint.y >= 0 && contentPoint.y <= calendarDayView.contentView.bounds.height {
                let durationInHours = templateView.template.duration / 60
                let previewHeight = CGFloat(durationInHours) * calendarDayView.hourHeight
                let startY = contentPoint.y - (previewHeight / 2)
                
                let maxStartY = calendarDayView.contentView.bounds.height - previewHeight
                let adjustedStartY = min(max(0, startY), maxStartY)
                
                let time = calendarDayView.positionToTime(position: adjustedStartY, roundToMinutes: 5)
                
                createEventFromTemplate(templateView.template, startTime: time)
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                previewView.alpha = 0
            }, completion: { _ in
                previewView.removeFromSuperview()
            })
            
            draggedTemplate = nil
            draggedEventPreview = nil
            
        default:
            break
        }
    }
    
    @objc private func handleTemplateDeleteTap(_ gesture: UITapGestureRecognizer) {
        guard isDeleteModeActive,
              let templateView = gesture.view as? EventTemplateView else { return }
        
        if let index = eventTemplates.firstIndex(where: { $0.id == templateView.template.id }) {
            let templateToDelete = eventTemplates[index]
            
            eventTemplates.remove(at: index)
            CoreDataManager.shared.deleteTemplate(templateToDelete)
            addTemplateItemsToStackView()
        }
    }
    
    @objc internal func toggleDeleteMode() {
        isDeleteModeActive = !isDeleteModeActive
        
        calendarDayView.deleteButton.tintColor = isDeleteModeActive ? .systemRed : nil
        addTemplateItemsToStackView()
    }
    
    // MARK: - Actions
    @objc private func addNewEvent() {
        let visibleMidY = calendarDayView.scrollView.contentOffset.y + calendarDayView.scrollView.bounds.height / 2
        let hour = Int(visibleMidY / calendarDayView.hourHeight)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startTime = calendar.date(bySettingHour: min(23, max(0, hour)), minute: 0, second: 0, of: today) ?? today
        let endTime = calendar.date(byAdding: .hour, value: 1, to: startTime) ?? today
        
        let event = CalendarEvent(
            title: "New Event",
            startTime: startTime,
            endTime: endTime,
            color: UIColor.systemBlue.withAlphaComponent(0.7)
        )
        
        events.append(event)
        addEventToView(event)
        editEvent(event)
        
        CoreDataManager.shared.saveEvent(event, for: currentDate)
    }
    
    // MARK: - Template Management
    @objc private func showAddTemplateScreen() {
        let addTemplateVC = AddTemplateViewController()
        addTemplateVC.delegate = self
        
        let navController = UINavigationController(rootViewController: addTemplateVC)
        present(navController, animated: true)
    }
    
    // MARK: - AddTemplateViewControllerDelegate
    func didAddTemplate(_ template: EventTemplate) {
        eventTemplates.append(template)
        CoreDataManager.shared.saveTemplate(template)
        addTemplateItemsToStackView()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isTemplateBeingDragged
    }
    
    // MARK: - EditEventViewControllerDelegate
    func didUpdateEvent(_ updatedEvent: CalendarEvent) {
        guard let index = events.firstIndex(where: { $0.id == updatedEvent.id }) else { return }
        
        events[index] = updatedEvent
        CoreDataManager.shared.saveEvent(updatedEvent, for: currentDate)
        
        if let eventView = eventViews[updatedEvent.id] {
            eventView.event = updatedEvent
            eventView.updateUI()
            
            let startY = calendarDayView.timeToPosition(event: updatedEvent.startTime)
            let endY = calendarDayView.timeToPosition(event: updatedEvent.endTime)
            let height = endY - startY
            
            eventView.frame = CGRect(
                x: eventView.frame.origin.x,
                y: startY,
                width: eventView.frame.width,
                height: height
            )
        }
    }
    
    func didDeleteEvent(_ event: CalendarEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        
        eventViews[event.id]?.removeFromSuperview()
        eventViews.removeValue(forKey: event.id)
        
        events.remove(at: index)
        CoreDataManager.shared.deleteEvent(event)
    }
    
    private func editEvent(_ event: CalendarEvent) {
        let editEventVC = EditEventViewController(event: event)
        editEventVC.delegate = self
        
        let navController = UINavigationController(rootViewController: editEventVC)
        present(navController, animated: true)
    }
    
    // MARK: - AIScheduleViewControllerDelegate
    @objc func showAIScheduleGenerator() {
        loadTemplates()
        
        let aiScheduleVC = AIScheduleViewController(date: currentDate, templates: eventTemplates)
        aiScheduleVC.delegate = self
        
        let navController = UINavigationController(rootViewController: aiScheduleVC)
        present(navController, animated: true)
    }
    
    func didGenerateSchedule(events: [CalendarEvent], for date: Date) {
        if !Calendar.current.isDate(date, inSameDayAs: currentDate) {
            changeDay(to: date)
        }
        
        for event in self.events {
            CoreDataManager.shared.deleteEvent(event)
            eventViews[event.id]?.removeFromSuperview()
        }
        
        eventViews.removeAll()
        self.events.removeAll()
        
        for event in events {
            self.events.append(event)
            addEventToView(event)
            CoreDataManager.shared.saveEvent(event, for: date)
        }
        
        let alert = UIAlertController(
            title: "Schedule Generated",
            message: "Your AI-generated schedule with \(events.count) activities has been created.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
