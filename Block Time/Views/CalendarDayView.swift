import UIKit

class CalendarDayView: UIView {
    // MARK: - Properties
    // Scroll components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let timelineView = UIView()
    let eventContainerView = UIView()
    
    // Template components
    let templateContainerView = UIView()
    let dividerView = UIView()
    var templateStackView: UIStackView!
    var dayTitleLabel: UILabel!
    var deleteButton: UIButton!
    
    // Dimensions
    let hourHeight: CGFloat = 90
    let timeColumnWidth: CGFloat = 50
    var dayViewWidth: CGFloat = 0
    let calendarHeightRatio: CGFloat = 0.65
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        dayViewWidth = frame.width - timeColumnWidth
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Setup Methods
    func setupLayout() {
        let calendarHeight = bounds.height * calendarHeightRatio
        
        let calendarContainer = UIView()
        calendarContainer.backgroundColor = .systemBackground
        addSubview(calendarContainer)
        
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            calendarContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            calendarContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            calendarContainer.heightAnchor.constraint(equalToConstant: calendarHeight)
        ])
        
        templateContainerView.backgroundColor = UIColor.systemGroupedBackground
        addSubview(templateContainerView)
        
        templateContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            templateContainerView.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor),
            templateContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            templateContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            templateContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        calendarContainer.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: calendarContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor)
        ])
        
        setupDivider()
    }
    
    func setupDivider() {
        dividerView.backgroundColor = UIColor.systemGray4
        addSubview(dividerView)
        
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: templateContainerView.topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setupScrollView() {
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentHeight: CGFloat = hourHeight * 24
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: contentHeight)
        ])
    }
    
    func setupTimelineView() {
        contentView.addSubview(timelineView)
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timelineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            timelineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timelineView.widthAnchor.constraint(equalToConstant: timeColumnWidth),
            timelineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setupHourLabels() {
        for hour in 0..<24 {
            let hourLabel = UILabel()
            
            let hourText: String
            if hour == 0 {
                hourText = "12 am"
            } else if hour < 12 {
                hourText = "\(hour) am"
            } else if hour == 12 {
                hourText = "12 pm"
            } else {
                hourText = "\(hour - 12) pm"
            }
            
            hourLabel.text = hourText
            hourLabel.font = UIFont.systemFont(ofSize: 12)
            hourLabel.textColor = .secondaryLabel
            hourLabel.textAlignment = .right
            
            timelineView.addSubview(hourLabel)
            hourLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let topPadding: CGFloat = hour == 0 ? -2 : -10
            
            NSLayoutConstraint.activate([
                hourLabel.topAnchor.constraint(equalTo: timelineView.topAnchor, constant: CGFloat(hour) * hourHeight + topPadding),
                hourLabel.leadingAnchor.constraint(equalTo: timelineView.leadingAnchor),
                hourLabel.trailingAnchor.constraint(equalTo: timelineView.trailingAnchor, constant: -8),
                hourLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            let separatorLine = UIView()
            separatorLine.backgroundColor = UIColor.systemGray5
            
            contentView.addSubview(separatorLine)
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                separatorLine.topAnchor.constraint(equalTo: timelineView.topAnchor, constant: CGFloat(hour) * hourHeight),
                separatorLine.leadingAnchor.constraint(equalTo: timelineView.trailingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
    }
    
    func setupCurrentTimeIndicator() {
        let currentTimeIndicator = UIView()
        currentTimeIndicator.backgroundColor = .systemRed
        
        contentView.addSubview(currentTimeIndicator)
        currentTimeIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: now)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        let currentTimePosition = CGFloat(hour) * hourHeight + CGFloat(minute) * hourHeight / 60
        
        NSLayoutConstraint.activate([
            currentTimeIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentTimePosition),
            currentTimeIndicator.leadingAnchor.constraint(equalTo: timelineView.trailingAnchor),
            currentTimeIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            currentTimeIndicator.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    func setupEventContainerView() {
        contentView.addSubview(eventContainerView)
        eventContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            eventContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            eventContainerView.leadingAnchor.constraint(equalTo: timelineView.trailingAnchor),
            eventContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            eventContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setupTemplateHeader() {
        let headerView = UIView()
        templateContainerView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Blocks"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .label
        
        let addTemplateButton = UIButton(type: .system)
        addTemplateButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        addTemplateButton.tag = 100 // Tag for identification in the controller
        
        let aiScheduleButton = UIButton(type: .system)
        aiScheduleButton.setImage(UIImage(systemName: "bolt"), for: .normal)
        aiScheduleButton.tag = 101 // Tag for identification in the controller
        
        deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tag = 102 // Tag for identification in the controller
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(addTemplateButton)
        headerView.addSubview(aiScheduleButton)
        headerView.addSubview(deleteButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addTemplateButton.translatesAutoresizingMaskIntoConstraints = false
        aiScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: templateContainerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: templateContainerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: templateContainerView.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            deleteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            deleteButton.widthAnchor.constraint(equalToConstant: 45),
            deleteButton.heightAnchor.constraint(equalToConstant: 45),
            
            aiScheduleButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            aiScheduleButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            aiScheduleButton.widthAnchor.constraint(equalToConstant: 45),
            aiScheduleButton.heightAnchor.constraint(equalToConstant: 45),
            
            addTemplateButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addTemplateButton.trailingAnchor.constraint(equalTo: aiScheduleButton.leadingAnchor, constant: -8),
            addTemplateButton.widthAnchor.constraint(equalToConstant: 50),
            addTemplateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Drag a block to add it to your day"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        
        templateContainerView.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 15),
            subtitleLabel.leadingAnchor.constraint(equalTo: templateContainerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: templateContainerView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 30),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setupTemplateScrollView() {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.alwaysBounceVertical = false
        
        templateContainerView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        templateStackView = UIStackView()
        templateStackView.axis = .horizontal
        templateStackView.spacing = 12
        templateStackView.alignment = .center
        templateStackView.distribution = .fillEqually
        
        scrollView.addSubview(templateStackView)
        templateStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: templateContainerView.subviews[1].bottomAnchor, constant: 5),
            scrollView.leadingAnchor.constraint(equalTo: templateContainerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: templateContainerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: templateContainerView.bottomAnchor, constant: -16),
            
            templateStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            templateStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            templateStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            templateStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            templateStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func updateTemplateScrollViewContentSize(templateWidth: CGFloat, templateCount: Int) {
        if let scrollView = templateStackView.superview as? UIScrollView {
            let contentWidth = CGFloat(templateCount) * (templateWidth + templateStackView.spacing) - templateStackView.spacing
            scrollView.contentSize = CGSize(width: max(contentWidth, scrollView.bounds.width - 32), height: templateStackView.bounds.height)
        }
    }
    
    func createDeleteOverlay() -> UIView {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.layer.cornerRadius = 8
        
        let imageView = UIImageView(image: UIImage(systemName: "minus.circle.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        
        overlay.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return overlay
    }
    
    // MARK: - Public Methods
    func scrollToCurrentTime() {
        DispatchQueue.main.async {
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.hour, .minute], from: now)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            
            let currentTimePosition = CGFloat(hour) * self.hourHeight + CGFloat(minute) * self.hourHeight / 60
            let contentHeight = self.contentView.bounds.height
            let visibleHeight = self.scrollView.bounds.height
            
            var scrollOffset = currentTimePosition - visibleHeight / 3
            let visibleBottomPosition = scrollOffset + visibleHeight
            
            if visibleBottomPosition > contentHeight {
                scrollOffset = contentHeight - visibleHeight
            }
            
            scrollOffset = max(0, scrollOffset)
            
            self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
        }
    }
    
    // MARK: - Helper Methods
    func timeToPosition(event date: Date) -> CGFloat {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        if calendar.isDate(date, equalTo: tomorrow, toGranularity: .minute) {
            return hourHeight * 24
        }
        
        return CGFloat(hour) * hourHeight + CGFloat(minute) * hourHeight / 60
    }
    
    func positionToTime(position: CGFloat, roundToMinutes: Int = 1) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let totalMinutes = position * 60 / hourHeight
        
        let clampedHours = min(23, max(0, Int(totalMinutes / 60)))
        var minutes = Int(totalMinutes.truncatingRemainder(dividingBy: 60))
        
        if minutes >= 60 {
            minutes = 59
        }
        
        if roundToMinutes > 1 {
            let remainder = minutes % roundToMinutes
            minutes = remainder >= roundToMinutes / 2 ? minutes + (roundToMinutes - remainder) : minutes - remainder
            
            if minutes == 60 {
                minutes = 0
                if clampedHours < 23 {
                    return calendar.date(bySettingHour: clampedHours + 1, minute: 0, second: 0, of: today) ?? today
                }
            }
        }
        
        return calendar.date(bySettingHour: clampedHours, minute: minutes, second: 0, of: today) ?? today
    }
}
