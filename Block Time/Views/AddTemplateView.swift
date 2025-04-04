import UIKit

class AddTemplateView: UIView {
    // MARK: - UI Components
    let titleTextField = UITextField()
    let hourPicker = UIPickerView()
    let minutePicker = UIPickerView()
    
    private(set) var colorButtons: [UIButton] = []
    let saveButton: UIButton
    let cancelButton: UIButton
    
    // MARK: - Private Properties
    private let hours = Array(0...12)
    private let minutes = Array(stride(from: 0, through: 55, by: 5))
    private let colors: [UIColor] = [
        UIColor.systemRed, UIColor.systemOrange, UIColor.systemYellow, UIColor.systemGreen, UIColor.systemTeal,
        UIColor.systemBlue, UIColor.systemIndigo, UIColor.systemPurple, UIColor.systemPink, UIColor.systemBrown
    ].map { $0.withAlphaComponent(0.7) }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        // Initialize buttons before super.init
        saveButton = AddTemplateView.createButton(
            title: "Save",
            backgroundColor: .systemBlue,
            titleColor: .white
        )
        
        cancelButton = AddTemplateView.createButton(
            title: "Cancel",
            backgroundColor: .systemGray5,
            titleColor: .systemBlue
        )
        
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        backgroundColor = .systemBackground
        
        setupTitleField()
        setupPickers()
        
        let colorStackViews = setupColorButtons()
        let firstRowStack = colorStackViews.0
        let secondRowStack = colorStackViews.1
        
        let titleLabel = createLabel(text: "Block Name")
        let durationLabel = createLabel(text: "Duration")
        let colorLabel = createLabel(text: "Color")
        
        let hoursLabel = createLabel(text: "hours", fontSize: 14)
        hoursLabel.textAlignment = .center
        
        let minutesLabel = createLabel(text: "minutes", fontSize: 14)
        minutesLabel.textAlignment = .center
        
        let durationStackView = UIStackView()
        durationStackView.axis = .horizontal
        durationStackView.distribution = .fill
        durationStackView.alignment = .center
        durationStackView.spacing = 5
        
        durationStackView.addArrangedSubview(hourPicker)
        durationStackView.addArrangedSubview(hoursLabel)
        durationStackView.addArrangedSubview(minutePicker)
        durationStackView.addArrangedSubview(minutesLabel)
        
        [titleLabel, titleTextField, durationLabel, durationStackView,
         colorLabel, firstRowStack, secondRowStack, saveButton, cancelButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [hourPicker, minutePicker, hoursLabel, minutesLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            durationLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            durationStackView.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            durationStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            durationStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            durationStackView.heightAnchor.constraint(equalToConstant: 120),
            
            hourPicker.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            hoursLabel.widthAnchor.constraint(equalToConstant: 50),
            minutePicker.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            minutesLabel.widthAnchor.constraint(equalToConstant: 70),
            
            colorLabel.topAnchor.constraint(equalTo: durationStackView.bottomAnchor, constant: 20),
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
            
            saveButton.topAnchor.constraint(equalTo: secondRowStack.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTitleField() {
        titleTextField.placeholder = "Block Name"
        titleTextField.borderStyle = .roundedRect
        titleTextField.clearButtonMode = .whileEditing
        titleTextField.returnKeyType = .done
    }
    
    private func setupPickers() {
        hourPicker.tag = 0
        minutePicker.tag = 1
    }
    
    private func createLabel(text: String, fontSize: CGFloat = 16) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        return label
    }
    
    static private func createButton(title: String, backgroundColor: UIColor, titleColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }
    
    private func setupColorButtons() -> (UIStackView, UIStackView) {
        let firstRowColorNames = ["Red", "Orange", "Yellow", "Green", "Teal"]
        let secondRowColorNames = ["Blue", "Indigo", "Purple", "Pink", "Brown"]
        
        let firstRowStack = createColorButtonStack()
        let secondRowStack = createColorButtonStack()
        
        for (index, colorName) in firstRowColorNames.enumerated() {
            let button = createColorButton(color: colors[index], name: colorName, tag: index)
            firstRowStack.addArrangedSubview(button)
            colorButtons.append(button)
        }
        
        for (index, colorName) in secondRowColorNames.enumerated() {
            let button = createColorButton(color: colors[index + 5], name: colorName, tag: index + 5)
            secondRowStack.addArrangedSubview(button)
            colorButtons.append(button)
            
            if index == 0 {
                button.layer.borderWidth = 3
                button.layer.borderColor = UIColor.white.cgColor
            }
        }
        
        return (firstRowStack, secondRowStack)
    }
    
    private func createColorButtonStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
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
    func selectColorButton(at index: Int) {
        for button in colorButtons {
            button.layer.borderWidth = button.tag == index ? 3 : 0
            button.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func getColorForIndex(_ index: Int) -> UIColor {
        return colors[index]
    }
    
    func getHours() -> [Int] {
        return hours
    }
    
    func getMinutes() -> [Int] {
        return minutes
    }
}
