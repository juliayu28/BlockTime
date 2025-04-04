//
//  EventView.swift
//  Block Time
//
//  Created by Julia Yu on 3/20/25.
//

import UIKit
class EventView: UIView {
    // MARK: - Properties
    var event: CalendarEvent
    
    // Handle views for resizing (these remain functional even when visual indicators are hidden)
    let topHandleView = UIView()
    let bottomHandleView = UIView()
    
    // Visual indicator bars (these will be hidden for short events)
    private let topBar = UIView()
    private let bottomBar = UIView()
    
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    let contentView = UIView()
    
    private var titleTopConstraint: NSLayoutConstraint!
    private var topHandleHeightConstraint: NSLayoutConstraint!
    private var bottomHandleHeightConstraint: NSLayoutConstraint!

    // MARK: - Initialization
    init(event: CalendarEvent) {
        self.event = event
        super.init(frame: .zero)
        setupViews()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        clipsToBounds = false
        contentView.backgroundColor = event.color
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Setup handle bars
        topBar.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        topBar.layer.cornerRadius = 2
        
        bottomBar.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        bottomBar.layer.cornerRadius = 2
        
        contentView.addSubview(topBar)
        contentView.addSubview(bottomBar)
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            topBar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            topBar.widthAnchor.constraint(equalToConstant: 40),
            topBar.heightAnchor.constraint(equalToConstant: 3),
            
            bottomBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bottomBar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bottomBar.widthAnchor.constraint(equalToConstant: 40),
            bottomBar.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        // Setup draggable handle areas (invisible)
        topHandleView.backgroundColor = UIColor.clear
        bottomHandleView.backgroundColor = UIColor.clear
        
        addSubview(topHandleView)
        addSubview(bottomHandleView)
        
        topHandleView.translatesAutoresizingMaskIntoConstraints = false
        bottomHandleView.translatesAutoresizingMaskIntoConstraints = false
        
        topHandleHeightConstraint = topHandleView.heightAnchor.constraint(equalToConstant: 15)
        bottomHandleHeightConstraint = bottomHandleView.heightAnchor.constraint(equalToConstant: 15)
        NSLayoutConstraint.activate([
            topHandleView.topAnchor.constraint(equalTo: topAnchor),
            topHandleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            topHandleView.widthAnchor.constraint(equalToConstant: 40), // Same width as top bar
            topHandleHeightConstraint,
            
            bottomHandleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomHandleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomHandleView.widthAnchor.constraint(equalToConstant: 40), // Same width as bottom bar
            bottomHandleHeightConstraint
        ])
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .white
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the title top constraint with a default value
        // We'll adjust this based on event duration in updateUI()
        titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            titleTopConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    // MARK: - UI Updates
    func updateUI() {
        contentView.backgroundColor = event.color
        titleLabel.text = event.title
        
        // Calculate event duration in minutes
        let durationInMinutes = event.endTime.timeIntervalSince(event.startTime) / 60
        
        // Format and set time label - Updated to use "h:mm a" format for 12-hour time with am/pm
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // This will show times like "9:00 AM" instead of "09:00"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        
        let startTimeString = dateFormatter.string(from: event.startTime)
        let endTimeString = dateFormatter.string(from: event.endTime)
        timeLabel.text = "\(startTimeString) - \(endTimeString)"
        
        // Hide time label for events shorter than 30 minutes
        timeLabel.isHidden = durationInMinutes < 30
        
        // Hide handle bars for events 20 minutes or shorter
        topBar.isHidden = durationInMinutes <= 20
        bottomBar.isHidden = durationInMinutes <= 20
        
        // Note: We don't hide topHandleView and bottomHandleView
        // as we still want the resizing functionality to work
        
        // Adjust title top padding based on event duration
        if durationInMinutes >= 30 && durationInMinutes <= 45 {
            // Reduced padding for medium-length events (30-45 minutes)
            titleTopConstraint.constant = 8
        } else if durationInMinutes <= 20 {
            titleTopConstraint.constant = 2.5
            topHandleHeightConstraint.constant = 10
            bottomHandleHeightConstraint.constant = 10
        } else {
            // Standard padding for longer events
            titleTopConstraint.constant = 16
        }
        
        // Update layout
        setNeedsLayout()
    }
}
