//
//  AIScheduleViewController.swift
//  Block Time
//
//  Created by Julia Yu on 3/28/25.
//
import UIKit

protocol AIScheduleViewControllerDelegate: AnyObject {
    func didGenerateSchedule(events: [CalendarEvent], for date: Date)
}

class AIScheduleViewController: UIViewController {
    
    // MARK: - Properties
    private var scheduleView: AIScheduleView!
    
    private var templates: [EventTemplate] = []
    private var selectedDate: Date
    private var generator: AIScheduleGenerator?
    
    weak var delegate: AIScheduleViewControllerDelegate?
    
    // MARK: - Initialization
    init(date: Date = Date(), templates: [EventTemplate] = []) {
        self.selectedDate = Calendar.current.startOfDay(for: date)
        self.templates = templates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.selectedDate = Calendar.current.startOfDay(for: Date())
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupView() {
        title = "AI Schedule Generator"
        
        // Create and configure the view
        scheduleView = AIScheduleView(frame: view.bounds)
        scheduleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scheduleView)
        
        // Setup navigation bar
        setupNavigationBar()
        
        // Setup view components
        scheduleView.setupDatePicker(selectedDate: selectedDate)
        scheduleView.setupTimeRangePickers()
        scheduleView.setupConstraintsField()
        scheduleView.setupTemplatesList(templates: templates)
        scheduleView.setupGenerateButton()
        
        // Configure table view delegate and data source
        if let tableView = scheduleView.getTemplatesTableView() {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    private func setupActions() {
        scheduleView.datePickerView.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        scheduleView.generateButton.addTarget(self, action: #selector(generateSchedule), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        var durationText = ""
        
        if hours > 0 {
            durationText += "\(hours) \(hours == 1 ? "hour" : "hours")"
        }
        
        if remainingMinutes > 0 {
            if !durationText.isEmpty {
                durationText += " "
            }
            durationText += "\(remainingMinutes) \(remainingMinutes == 1 ? "minute" : "minutes")"
        }
        
        return durationText
    }
    
    private func hideLoadingWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.scheduleView.hideLoadingView()
        }
    }
    
    // MARK: - Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = Calendar.current.startOfDay(for: sender.date)
    }
    
    @objc private func generateSchedule() {
        guard !templates.isEmpty else {
            showAlert(title: "No Templates", message: "Please create some activity blocks first.")
            return
        }
        
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: scheduleView.startTimePicker.date)
        let endComponents = calendar.dateComponents([.hour, .minute], from: scheduleView.endTimePicker.date)
        
        guard let startHour = startComponents.hour,
              let endHour = endComponents.hour else {
            showAlert(title: "Invalid Time Range", message: "Please select valid start and end times.")
            return
        }
        
        scheduleView.updateLoadingState(isGenerating: true, message: "Generating schedule...")
        
        generator = AIScheduleGenerator()
        generator?.generateSchedule(
            templates: templates,
            date: selectedDate,
            startHour: startHour,
            endHour: endHour,
            constraints: scheduleView.constraintsTextView.text
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let events):
                if events.isEmpty {
                    self.scheduleView.updateLoadingState(isGenerating: false, message: "No events generated. Try different constraints.", messageColor: .systemOrange)
                    self.hideLoadingWithDelay()
                } else {
                    self.scheduleView.showSuccessState()
                    self.delegate?.didGenerateSchedule(events: events, for: self.selectedDate)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.scheduleView.hideLoadingView()
                        self.dismiss(animated: true)
                    }
                }
                
            case .failure(let error):
                self.scheduleView.updateLoadingState(isGenerating: false, message: "Error: \(error.localizedDescription)", messageColor: .systemRed)
                self.hideLoadingWithDelay()
            }
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension AIScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath)
        let template = templates[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = template.title
        config.secondaryText = formatDuration(minutes: Int(template.duration))
        
        let colorView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        colorView.backgroundColor = template.color
        colorView.layer.cornerRadius = 5
        cell.accessoryView = colorView
        
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        
        return cell
    }
}
