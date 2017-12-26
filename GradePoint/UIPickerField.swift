//
//  UIPickerField.swift
//  GradePoint
//
//  Created by Luis Padron on 12/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class UIPickerField: UIFloatingPromptTextField {
    
    // MARK: Properties
    
    public weak var pickerDelegate: UIPickerFieldDelegate?
    
    public weak var pickerDataSource: UIPickerFieldDataSource?
    
    public var handlesSettingTextManually: Bool = false
    
    // MARK: Initializers
    
    required init(frame: CGRect, fieldType: FieldType, configuration: FieldConfiguration) {
        super.init(frame: frame, fieldType: fieldType, configuration: configuration)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    // MARK: Helpers
    
    private func initialize() {
        self.inputView = pickerView
        self.inputAccessoryView = toolbar
    }
    
    // MARK: Actions
    
    @objc private func doneButtonTouched() {
        self.pickerDelegate?.doneButtonTouched(for: self)
    }
    
    // MARK: Subviews
    
    lazy var toolbarLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width / 3, height: self.frame.size.height))
        label.font = UIFont.systemFont(ofSize: 18)
        label.backgroundColor = .clear
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Toolbar label"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var toolbar: UIToolbar = {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 40))
        bar.tintColor = self.tintColor
        bar.barTintColor = .white
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTouched))
        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let textButton = UIBarButtonItem(customView: self.toolbarLabel)
        bar.setItems([spacing, textButton, spacing, doneButton], animated: false)
        
        return bar
    }()
    
    lazy var pickerView: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        return view
    }()
}

// MARK: UIPickerViewDelegate & UIPickerViewDataSource conformance

extension UIPickerField: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if !self.handlesSettingTextManually { self.text = self.pickerDataSource?.titleForRow(row, in: component, for: self) ?? "" }
        self.pickerDelegate?.didSelectPickerRow(row, in: component, for: self)
    }
}

extension UIPickerField: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.pickerDataSource?.numberOfComponents(in: self) ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerDataSource?.numberOfRows(in: component, for: self) ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerDataSource?.titleForRow(row, in: component, for: self)
    }
}
