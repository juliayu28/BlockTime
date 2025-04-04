import UIKit

protocol EditEventViewControllerDelegate: AnyObject {
    func didUpdateEvent(_ event: CalendarEvent)
    func didDeleteEvent(_ event: CalendarEvent)
}

class EditEventViewController: UIViewController {
    
    // MARK: - Properties
    internal var editEventView: EditEventView!
    internal var selectedColor: UIColor
    internal var startDate: Date
    internal var endDate: Date
    private let event: CalendarEvent
    
    weak var delegate: EditEventViewControllerDelegate?
    
    // MARK: - Initialization
    init(event: CalendarEvent) {
        self.event = event
        self.selectedColor = event.color
        self.startDate = event.startTime
        self.endDate = event.endTime
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupEventHandlers()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup
    private func setupView() {
        title = "Edit Event"
        
        editEventView = EditEventView(frame: view.bounds)
        editEventView.configure(with: event)
        view.addSubview(editEventView)
        
        editEventView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editEventView.topAnchor.constraint(equalTo: view.topAnchor),
            editEventView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editEventView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editEventView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set delegates
        editEventView.titleTextField.delegate = self
    }
    
    private func setupEventHandlers() {
        // Configure color button actions
        let firstRowButtons = editEventView.firstRowStack.arrangedSubviews as? [UIButton] ?? []
        let secondRowButtons = editEventView.secondRowStack.arrangedSubviews as? [UIButton] ?? []
        
        for button in firstRowButtons + secondRowButtons {
            button.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
        }
        
        // Configure date picker actions
        editEventView.startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        editEventView.endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)
        
        // Configure button actions
        editEventView.saveButton.addTarget(self, action: #selector(saveEvent), for: .touchUpInside)
        editEventView.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    private func updateTimeComponent(from picker: UIDatePicker, for originalDate: Date) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: picker.date)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: originalDate)
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        return calendar.date(from: dateComponents)
    }
    
    // MARK: - Actions
    @objc private func colorButtonTapped(_ sender: UIButton) {
        let colors = editEventView.getColors()
        selectedColor = colors[sender.tag]
        
        editEventView.selectColorButton(for: selectedColor)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc internal func saveEvent() {
        guard let title = editEventView.titleTextField.text, !title.isEmpty else {
            showAlert(title: "Invalid Input", message: "Please provide a valid name for your block.")
            return
        }
        
        if startDate >= endDate {
            showAlert(title: "Invalid Time Range", message: "The start time must be before the end time.")
            return
        }
        
        let updatedEvent = CalendarEvent(
            id: event.id,
            title: title,
            startTime: startDate,
            endTime: endDate,
            color: selectedColor
        )
        
        delegate?.didUpdateEvent(updatedEvent)
        dismiss(animated: true)
    }
    
    @objc internal func deleteEvent() {
        delegate?.didDeleteEvent(event)
        dismiss(animated: true)
    }
    
    @objc private func startTimeChanged(_ sender: UIDatePicker) {
        if let newDate = updateTimeComponent(from: sender, for: startDate) {
            startDate = newDate
        }
    }
    
    @objc private func endTimeChanged(_ sender: UIDatePicker) {
        if let newDate = updateTimeComponent(from: sender, for: endDate) {
            endDate = newDate
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
