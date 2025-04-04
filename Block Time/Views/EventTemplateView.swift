//
//  EventTemplateView.swift
//  Block Time
//
//  Created by Julia Yu on 3/20/25.
//
import UIKit

class EventTemplateView: UIView {
    let template: EventTemplate
    private let titleLabel = UILabel()
    private let durationLabel = UILabel()
    
    init(template: EventTemplate) {
        self.template = template
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = template.color
        layer.cornerRadius = 8
        clipsToBounds = false  // Allow subviews to exceed bounds for the delete indicator
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2
        
        titleLabel.text = template.title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        // Configure duration label
        let durationInMinutes = Int(template.duration)
        if durationInMinutes >= 60 {
            let hours = durationInMinutes / 60
            let minutes = durationInMinutes % 60
            
            if minutes == 0 {
                durationLabel.text = "\(hours) hr"
            } else {
                durationLabel.text = "\(hours) hr \(minutes) min"
            }
        } else {
            durationLabel.text = "\(durationInMinutes) min"
        }
        
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        durationLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        durationLabel.textAlignment = .center
        
        addSubview(titleLabel)
        addSubview(durationLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            durationLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }
    
    // Add animation for delete mode
    func applyDeleteEffect() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.7
        })
    }
    
    // Reset animation when exiting delete mode
    func resetDeleteEffect() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = .identity
            self.alpha = 1.0
        })
    }
}
