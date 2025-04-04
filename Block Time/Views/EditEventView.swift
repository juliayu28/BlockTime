import UIKit

class EditEventView: UIView {
    
    // MARK: - Properties
    let titleTextField = UITextField()
    let startTimePicker = UIDatePicker()
    let endTimePicker = UIDatePicker()
    var firstRowStack: UIStackView!
    var secondRowStack: UIStackView!
    private var colorButtons = [UIButton]()
    
    let saveButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .systemBackground
        
        setupTitleField()
        setupTimePickers()
        setupColorSelection()
        setupButtons()
    }
    
    private func setupTitleField() {
        let titleLabel = createLabel(text: "Event Name")
        
        titleTextField.placeholder = "Event Name"
        titleTextField.borderStyle = .roundedRect
        titleTextField.clearButtonMode = .whileEditing
        titleTextField.returnKeyType = .done
        
        addSubview(titleLabel)
        addSubview(titleTextField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
    
    private func setupTimePickers() {
        let startTimeLabel = createLabel(text: "Start Time")
        let endTimeLabel = createLabel(text: "End Time")
        
        configureTimePicker(startTimePicker)
        configureTimePicker(endTimePicker)
        
        let startTimeContainer = createTimePickerContainer(with: startTimePicker)
        let endTimeContainer = createTimePickerContainer(with: endTimePicker)
        
        addSubview(startTimeLabel)
        addSubview(startTimeContainer)
        addSubview(endTimeLabel)
        addSubview(endTimeContainer)
        
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeContainer.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startTimeLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            startTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            startTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            startTimeContainer.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 8),
            startTimeContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            startTimeContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            startTimeContainer.heightAnchor.constraint(equalToConstant: 90),
            
            endTimeLabel.topAnchor.constraint(equalTo: startTimeContainer.bottomAnchor, constant: 50),
            endTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            endTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            endTimeContainer.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 8),
            endTimeContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            endTimeContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            endTimeContainer.heightAnchor.constraint(equalToConstant: 90),
        ])
    }
    
    private func setupColorSelection() {
        let colorLabel = createLabel(text: "Color")
        addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let colors = getColors()
        let firstRowColorNames = ["Red", "Orange", "Yellow", "Green", "Teal"]
        let secondRowColorNames = ["Blue", "Indigo", "Purple", "Pink", "Brown"]
        
        firstRowStack = createColorButtonStack()
        secondRowStack = createColorButtonStack()
        
        addColorButtons(to: firstRowStack, with: firstRowColorNames, colors: colors, startIndex: 0)
        addColorButtons(to: secondRowStack, with: secondRowColorNames, colors: colors, startIndex: 5)
        
        addSubview(firstRowStack)
        addSubview(secondRowStack)
        
        firstRowStack.translatesAutoresizingMaskIntoConstraints = false
        secondRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: endTimePicker.superview!.bottomAnchor, constant: 38),
            colorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            colorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            firstRowStack.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            firstRowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            firstRowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            firstRowStack.heightAnchor.constraint(equalToConstant: 50),
            
            secondRowStack.topAnchor.constraint(equalTo: firstRowStack.bottomAnchor, constant: 8),
            secondRowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            secondRowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            secondRowStack.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func setupButtons() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        
        deleteButton.setTitle("Delete Event", for: .normal)
        deleteButton.backgroundColor = .systemRed.withAlphaComponent(0.8)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 8
        
        addSubview(saveButton)
        addSubview(deleteButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: secondRowStack.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Helper Methods
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }
    
    private func configureTimePicker(_ picker: UIDatePicker) {
        picker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.minuteInterval = 5
    }
    
    private func createTimePickerContainer(with picker: UIDatePicker) -> UIView {
        let container = UIView()
        container.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            picker.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            picker.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
            picker.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        return container
    }
    
    func getColors() -> [UIColor] {
        return [
            .systemRed.withAlphaComponent(0.7),
            .systemOrange.withAlphaComponent(0.7),
            .systemYellow.withAlphaComponent(0.7),
            .systemGreen.withAlphaComponent(0.7),
            .systemTeal.withAlphaComponent(0.7),
            .systemBlue.withAlphaComponent(0.7),
            .systemIndigo.withAlphaComponent(0.7),
            .systemPurple.withAlphaComponent(0.7),
            .systemPink.withAlphaComponent(0.7),
            .systemBrown.withAlphaComponent(0.7)
        ]
    }
    
    private func createColorButtonStack() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }
    
    private func addColorButtons(to stackView: UIStackView, with names: [String], colors: [UIColor], startIndex: Int) {
        for (index, colorName) in names.enumerated() {
            let actualIndex = index + startIndex
            let button = createColorButton(color: colors[actualIndex], name: colorName, tag: actualIndex)
            stackView.addArrangedSubview(button)
            colorButtons.append(button)
        }
    }
    
    private func createColorButton(color: UIColor, name: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = color
        button.setTitle(name, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.tag = tag
        button.layer.cornerRadius = 8
        return button
    }
    
    // MARK: - Public Methods
    func configure(with event: CalendarEvent) {
        titleTextField.text = event.title
        startTimePicker.date = event.startTime
        endTimePicker.date = event.endTime
        
        // Select the color button
        selectColorButton(for: event.color)
    }
    
    func selectColorButton(for color: UIColor) {
        let colors = getColors()
        for (index, colorButton) in colorButtons.enumerated() {
            let buttonColor = colors[colorButton.tag]
            let isSelected = buttonColor.isEqual(color)
            colorButton.layer.borderWidth = isSelected ? 3 : 0
            colorButton.layer.borderColor = UIColor.white.cgColor
        }
    }
}
