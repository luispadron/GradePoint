//
//  UIGradePercentageView.swift
//  GradePoint
//
//  Created by Luis Padron on 5/4/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

@IBDesignable
class UIGradePercentageView: UIView {

    // MARK: Members

    @IBInspectable public var gradeLetter: String = "A+" {
        didSet {
            self.label.text = self.gradeLetter
        }
    }

    @IBInspectable public var upperLowerMode: Bool = true {
        didSet {
            self.fieldSeperator.isHidden = !self.upperLowerMode
            self.upperBoundField.isHidden = !self.upperLowerMode

            if !self.upperLowerMode {
                self.lowerBoundField.removeConstraints(self.lowerBoundField.constraints)
            }

            self.layoutIfNeeded()
        }
    }


    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    private func initialize() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.label)
        self.addSubview(self.holder)

        // Add constraints
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24).isActive = true
        self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        self.holder.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24).isActive = true
        self.holder.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.holder.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.holder.widthAnchor.constraint(equalToConstant: 200).isActive = true

        self.lowerBoundField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.lowerBoundField.widthAnchor.constraint(equalToConstant: 65).isActive = true

        self.upperBoundField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.upperBoundField.widthAnchor.constraint(equalToConstant: 65).isActive = true

        self.fieldSeperator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        self.fieldSeperator.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }

    // MARK: Helpers

    // A 'Cancel' and 'Done' button toolbar
    private var fieldToolbar: UIToolbar = {
        let fieldToolbar = UIToolbar()
        fieldToolbar.barStyle = .default
        fieldToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(accessoryKeyboardDone)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(accessoryKeyboardDone))
        ]
        fieldToolbar.sizeToFit()
        fieldToolbar.barTintColor = ApplicationTheme.shared.highlightColor
        fieldToolbar.isTranslucent = false
        fieldToolbar.tintColor = .white
        return fieldToolbar
    }()

    // The configuration for the fields
    private var percentConfig: PercentConfiguration = {
        let config = PercentConfiguration(allowsOver100: true, allowsFloatingPoint: true)
        return config
    }()

    // MARK: Actions

    @objc private func accessoryKeyboardDone(button: UIBarButtonItem) {
        self.lowerBoundField.resignFirstResponder()
        self.upperBoundField.resignFirstResponder()
    }

    // MARK: Subviews

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.gradeLetter
        label.textColor = ApplicationTheme.shared.mainTextColor()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    private lazy var holder: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.lowerBoundField, self.fieldSeperator, self.upperBoundField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }()

    public lazy var lowerBoundField: UISafeTextField = {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let field = UISafeTextField(frame: frame, fieldType: .percent, configuration: percentConfig)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        field.placeholder = "Lower"
        field.inputAccessoryView = self.fieldToolbar
        return field
    }()

    private lazy var fieldSeperator: UIView = {
        let seperator = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 2))
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .gray
        return seperator
    }()

    public lazy var upperBoundField: UISafeTextField = {
        let field = UISafeTextField(frame: frame, fieldType: .percent, configuration: percentConfig)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textAlignment = .right
        field.delegate = self
        field.placeholder = "Upper"
        field.inputAccessoryView = self.fieldToolbar
        return field
    }()

}

extension UIGradePercentageView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let safeField = textField as? UISafeTextField else { return true }
        return safeField.shouldChangeTextAfterCheck(text: string)
    }
}
