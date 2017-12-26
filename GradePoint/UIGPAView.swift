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
        field.textColor = UIColor.secondaryTextColor()
        field.borderStyle = .none
        field.tintColor = .pastelPurple
        field.isUserInteractionEnabled = false
        field.attributedPlaceholder = NSAttributedString(string: "Name",
                                                         attributes: [.foregroundColor: UIColor.secondaryTextColor()])
        field.returnKeyType = .next
        field.font = self.font
        
        return field
    }()
    
    /// The grade field which displays the grade letter of the class
    lazy var gradeField: UIPickerField = {
        let field = UIPickerField(frame: .zero, fieldType: .text, configuration: TextConfiguration(maxCharacters: 2))
        field.placeholder = "Grade"
        field.titleText = "Grade"
        field.titleTextColor = .pastelPurple
        field.textColor = UIColor.mainTextColor()
        field.borderStyle = .none
        field.tintColor = .pastelPurple
        field.attributedPlaceholder = NSAttributedString(string: "Grade",
                                                         attributes: [.foregroundColor: UIColor.secondaryTextColor()])
        field.returnKeyType = .next
        field.font = self.font
        field.pickerDelegate = self
        field.pickerDataSource = self
        field.toolbar.barTintColor = .pastelPurple
        field.toolbar.tintColor = .white
        field.toolbarLabel.text = "Select a grade"
        
        return field
    }()
    
    lazy var creditsField: UIFloatingPromptTextField = {
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .text, configuration: TextConfiguration())
        field.placeholder = "Credits"
        field.titleText = "Credits"
        field.titleTextColor = .pastelPurple
        field.textColor = UIColor.secondaryTextColor()
        field.borderStyle = .none
        field.tintColor = .pastelPurple
        field.isUserInteractionEnabled = false
        field.attributedPlaceholder = NSAttributedString(string: "Credits",
                                                         attributes: [.foregroundColor: UIColor.secondaryTextColor()])
        field.returnKeyType = .next
        field.font = self.font
        
        return field
    }()
}

// MARK: PickerField Delegation

extension UIGPAView: UIPickerFieldDelegate, UIPickerFieldDataSource {
    
    // The grades which can be picked from the picker
    var grades: [String] {
        let scale = DatabaseManager.shared.realm.objects(GPAScale.self)[0]
        return scale.gpaRubrics.map { $0.gradeLetter }
    }
    
    func numberOfComponents(in field: UIPickerField) -> Int {
        return 1
    }
    
    func numberOfRows(in compononent: Int, for field: UIPickerField) -> Int {
        return grades.count
    }
    
    func titleForRow(_ row: Int, in component: Int, for field: UIPickerField) -> String? {
        return grades[row]
    }
    
    func didSelectPickerRow(_ row: Int, in component: Int, for field: UIPickerField) { }
    
    func doneButtonTouched(for field: UIPickerField) {
        self.gradeField.resignFirstResponder()
    }
}
