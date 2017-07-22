//
//  UIGPAView.swift
//  GradePoint
//
//  Created by Luis Padron on 5/4/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class UIGPAView: UIView {
    
    // MARK: View Properties
    
    var font: UIFont = UIFont.systemFont(ofSize: 18)
    
    
    // MARK: Actions
    
    @objc private func tappedOnDoneGradeFieldButton(sender: UIBarButtonItem) {
        // End editing
        self.gradeField.resignFirstResponder()
    }
    
    // MARK: Overrides
    
    // MARK: Initializers/Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightBackground
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.lightBackground
        self.initialize()
    }
    
    private func initialize() {
        self.addSubview(nameField)
        self.addSubview(gradeField)
        self.addSubview(creditsField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = self.frame.height
        let width = self.frame.width
        
        // Set frames
        nameField.frame = CGRect(x: 8, y: 0, width: width * 0.50 - 8, height: height)
        gradeField.frame = CGRect(x: nameField.frame.maxX + 20, y: 0, width: width * 0.25 - 20, height: height)
        creditsField.frame = CGRect(x: gradeField.frame.maxX + 20, y: 0, width: width * 0.25 - 20, height: height)
    }
    
    
    // MARK: Subviews
    
    /// The name field for the GPA View, not editable
    lazy var nameField: UIFloatingPromptTextField = {
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .text, configuration: TextConfiguration())
        field.placeholder = "Name"
        field.titleText = "Name"
        field.titleTextColor = .pastelPurple
        field.textColor = .mutedText
        field.borderStyle = .none
        field.tintColor = .pastelPurple
        field.isUserInteractionEnabled = false
        field.attributedPlaceholder = NSAttributedString(string: "Name",
                                                         attributes: [.foregroundColor: UIColor.mutedText])
        field.returnKeyType = .next
        field.font = self.font
        
        return field
    }()
    
    /// The grade field which displays the grade letter of the class
    lazy var gradeField: UIFloatingPromptTextField = {
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .text,
                                              configuration: TextConfiguration(maxCharacters: 2))
        field.placeholder = "Grade"
        field.titleText = "Grade"
        field.titleTextColor = .pastelPurple
        field.textColor = UIColor.mainTextColor()
        field.borderStyle = .none
        field.tintColor = .pastelPurple
        field.attributedPlaceholder = NSAttributedString(string: "Grade",
                                                         attributes: [.foregroundColor: UIColor.mutedText])
        field.returnKeyType = .next
        field.font = self.font
        // Add the picker view as an input view
        field.inputView = self.gradesPickerView
        // Add toolbar to field
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 40))
        toolBar.layer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height-20.0)
        toolBar.tintColor = .white
        toolBar.barTintColor = .pastelPurple
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.tappedOnDoneGradeFieldButton(sender:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width / 3, height: self.frame.size.height))
        label.font = UIFont.systemFont(ofSize: 18)
        label.backgroundColor = .clear
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Select a grade"
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace, textBtn, flexSpace, doneButton], animated: false)
        field.inputAccessoryView = toolBar
        label.adjustsFontSizeToFitWidth = true
        
        return field
    }()
    
    lazy var creditsField: UIFloatingPromptTextField = {
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .text, configuration: TextConfiguration())
        field.placeholder = "Credits"
        field.titleText = "Credits"
        field.titleTextColor = .pastelPurple
        field.textColor = .mutedText
        field.borderStyle = .none
        field.tintColor = .pastelPurple
        field.isUserInteractionEnabled = false
        field.attributedPlaceholder = NSAttributedString(string: "Credits",
                                                         attributes: [.foregroundColor: UIColor.mutedText])
        field.returnKeyType = .next
        field.font = self.font
        
        return field
    }()
    
    /// The picker view which acts as an input view for the GradeField
    lazy var gradesPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        return picker
    }()
    
}

// MARK: Pickerview Delegation

extension UIGPAView: UIPickerViewDelegate, UIPickerViewDataSource {
    // The grades which can be picked from the picker
    var grades: [String] {
        get {
            let scale = DatabaseManager.shared.realm.objects(GPAScale.self)[0]
            return scale.gpaRubrics.map { $0.gradeLetter }
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return grades.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return grades[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.gradeField.text = grades[row]
    }
}
