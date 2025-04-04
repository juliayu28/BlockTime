import UIKit

protocol AddTemplateViewControllerDelegate: AnyObject {
    func didAddTemplate(_ template: EventTemplate)
}

class AddTemplateViewController: UIViewController {
    
    // MARK: - Properties
    internal var addTemplateView: AddTemplateView!
    internal var selectedColor: UIColor = .systemBlue.withAlphaComponent(0.7)
    internal var selectedHours = 0
    internal var selectedMinutes = 0
    
    weak var delegate: AddTemplateViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup
    private func setupView() {
        title = "Add New Block"
        
        addTemplateView = AddTemplateView(frame: view.bounds)
        addTemplateView.titleTextField.delegate = self
        addTemplateView.hourPicker.delegate = self
        addTemplateView.hourPicker.dataSource = self
        addTemplateView.minutePicker.delegate = self
        addTemplateView.minutePicker.dataSource = self
        
        view.addSubview(addTemplateView)
        
        addTemplateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addTemplateView.topAnchor.constraint(equalTo: view.topAnchor),
            addTemplateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addTemplateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addTemplateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Default selection
        selectedColor = addTemplateView.getColorForIndex(5) // Blue (index 5)
    }
    
    private func setupActions() {
        // Add targets to buttons
        addTemplateView.saveButton.addTarget(self, action: #selector(saveTemplate), for: .touchUpInside)
        addTemplateView.cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        // Add targets to color buttons
        for button in addTemplateView.colorButtons {
            button.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
        }
    }
    
    // MARK: - Actions
    @objc private func colorButtonTapped(_ sender: UIButton) {
        selectedColor = addTemplateView.getColorForIndex(sender.tag)
        addTemplateView.selectColorButton(at: sender.tag)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc internal func saveTemplate() {
        guard let title = addTemplateView.titleTextField.text, !title.isEmpty else {
            showAlert(title: "Invalid Input", message: "Please provide a valid name for your block.")
            return
        }
        
        let totalDurationMinutes = (selectedHours * 60) + selectedMinutes
        
        if totalDurationMinutes == 0 {
            showAlert(title: "Invalid Duration", message: "Please select a duration greater than 0.")
            return
        }
        
        let template = EventTemplate(
            title: title,
            duration: Double(totalDurationMinutes),
            color: selectedColor
        )
        
        delegate?.didAddTemplate(template)
        dismiss(animated: true)
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
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddTemplateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension AddTemplateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 0 ? addTemplateView.getHours().count : addTemplateView.getMinutes().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return "\(addTemplateView.getHours()[row])"
        } else {
            return "\(addTemplateView.getMinutes()[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            selectedHours = addTemplateView.getHours()[row]
        } else {
            selectedMinutes = addTemplateView.getMinutes()[row]
        }
    }
}
