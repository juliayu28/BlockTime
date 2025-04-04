//
//  AIScheduleView.swift
//  Block Time
//
//  Created on 3/29/25.
//

import UIKit

class AIScheduleView: UIView {
    
    // MARK: - UI Elements
    let scrollView = UIScrollView()
    let contentView = UIStackView()
    
    let datePickerView = UIDatePicker()
    let startTimePicker = UIDatePicker()
    let endTimePicker = UIDatePicker()
    let constraintsTextView = UITextView()
    let loadingContainerView = UIView()
    let checkmarkImageView = UIImageView()
    let generateButton = UIButton(type: .system)
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let statusLabel = UILabel()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentView()
        setupLoadingView()
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupContentView() {
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.alignment = .fill
        contentView.distribution = .fill
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setupDatePicker(selectedDate: Date) {
        let dateStack = createVerticalStack(spacing: 8)
        let titleLabel = createSectionTitleLabel(text: "Schedule Date")
        dateStack.addArrangedSubview(titleLabel)
        
        datePickerView.datePickerMode = .date
        datePickerView.preferredDatePickerStyle = .inline
        datePickerView.date = selectedDate
        dateStack.addArrangedSubview(datePickerView)
        
        contentView.addArrangedSubview(dateStack)
    }
    
    func setupTimeRangePickers() {
        let timeStack = createVerticalStack(spacing: 8)
        timeStack.addArrangedSubview(createSectionTitleLabel(text: "Time Range"))
        
        // Start time picker
        let startStack = createHorizontalStack()
        let startLabel = createTimeLabel(text: "Start:")
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimePicker.date = createTimeDate(hour: 9, minute: 0)
        
        startStack.addArrangedSubview(startLabel)
        startStack.addArrangedSubview(startTimePicker)
        
        // End time picker
        let endStack = createHorizontalStack()
        let endLabel = createTimeLabel(text: "End:")
        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.date = createTimeDate(hour: 21, minute: 0)
        
        endStack.addArrangedSubview(endLabel)
        endStack.addArrangedSubview(endTimePicker)
        
        timeStack.addArrangedSubview(startStack)
        timeStack.addArrangedSubview(endStack)
        
        contentView.addArrangedSubview(timeStack)
    }
    
    func setupConstraintsField() {
        let constraintsStack = createVerticalStack(spacing: 8)
        constraintsStack.addArrangedSubview(createSectionTitleLabel(text: "Additional Preferences (Optional)"))
        
        constraintsTextView.font = UIFont.systemFont(ofSize: 16)
        constraintsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        constraintsTextView.layer.borderWidth = 1
        constraintsTextView.layer.cornerRadius = 8
        constraintsTextView.isScrollEnabled = true
        constraintsTextView.autocorrectionType = .yes
        constraintsTextView.autocapitalizationType = .sentences
        constraintsTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        constraintsStack.addArrangedSubview(constraintsTextView)
        contentView.addArrangedSubview(constraintsStack)
    }
    
    func setupTemplatesList(templates: [EventTemplate]) {
        let templatesStack = createVerticalStack(spacing: 8)
        templatesStack.addArrangedSubview(createSectionTitleLabel(text: "Available Activity Blocks"))
        
        if templates.isEmpty {
            templatesStack.addArrangedSubview(createEmptyTemplatesLabel())
        } else {
            templatesStack.addArrangedSubview(createTemplateListView(templates: templates))
        }
        
        contentView.addArrangedSubview(templatesStack)
    }
    
    private func createEmptyTemplatesLabel() -> UILabel {
        let emptyLabel = UILabel()
        emptyLabel.text = "No activity blocks found. Please create some templates first."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return emptyLabel
    }
    
    func createTemplateListView(templates: [EventTemplate]) -> UIView {
        let containerView = UIView()
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TemplateCell")
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tag = 100 // Tag for identification
        
        containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        let rowHeight: CGFloat = 45
        let tableHeight = CGFloat(templates.count) * rowHeight
        containerView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
        
        return containerView
    }
    
    func setupGenerateButton() {
        generateButton.setTitle("Generate Schedule", for: .normal)
        generateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        generateButton.backgroundColor = .systemBlue
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 12
        generateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        contentView.addArrangedSubview(generateButton)
    }
    
    private func setupLoadingView() {
        loadingContainerView.backgroundColor = .white
        loadingContainerView.layer.cornerRadius = 10
        loadingContainerView.layer.shadowColor = UIColor.black.cgColor
        loadingContainerView.layer.shadowOpacity = 0.25
        loadingContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        loadingContainerView.layer.shadowRadius = 3
        loadingContainerView.layer.masksToBounds = false
        loadingContainerView.isHidden = true
        
        addSubview(loadingContainerView)
        loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingContainerView.widthAnchor.constraint(equalToConstant: 180),
            loadingContainerView.heightAnchor.constraint(equalToConstant: 135)
        ])
        
        setupLoadingIndicator()
        setupCheckmarkImage()
        setupStatusLabel()
    }
    
    private func setupLoadingIndicator() {
        activityIndicator.color = .systemBlue
        activityIndicator.hidesWhenStopped = true
        loadingContainerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loadingContainerView.topAnchor, constant: 28)
        ])
    }
    
    private func setupCheckmarkImage() {
        let checkmarkConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: checkmarkConfig)
        checkmarkImageView.tintColor = .systemGreen
        checkmarkImageView.isHidden = true
        loadingContainerView.addSubview(checkmarkImageView)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor)
        ])
    }
    
    private func setupStatusLabel() {
        statusLabel.text = ""
        statusLabel.textAlignment = .center
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        loadingContainerView.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor, constant: -12)
        ])
    }
    
    // MARK: - Helper Methods
    func getTemplatesTableView() -> UITableView? {
        return viewWithTag(100) as? UITableView
    }
    
    func createVerticalStack(spacing: CGFloat) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = spacing
        return stack
    }
    
    func createHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }
    
    func createTimeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        return label
    }
    
    func createTimeDate(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func createSectionTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }
    
    // MARK: - View State Updates
    func updateLoadingState(isGenerating: Bool, message: String, messageColor: UIColor = .secondaryLabel) {
        activityIndicator.isHidden = !isGenerating
        checkmarkImageView.isHidden = true
        
        if isGenerating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        loadingContainerView.isHidden = false
        generateButton.isEnabled = !isGenerating
        statusLabel.text = message
        statusLabel.textColor = messageColor
    }
    
    func showSuccessState() {
        activityIndicator.isHidden = true
        checkmarkImageView.isHidden = false
        statusLabel.text = "Schedule generated successfully!"
        statusLabel.textColor = .systemGreen
    }
    
    func hideLoadingView() {
        loadingContainerView.isHidden = true
    }
}
