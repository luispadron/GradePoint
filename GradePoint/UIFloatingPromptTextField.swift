//
//  UITextFieldExtension.swift
//  UIAnimatedTextField
//
//  Created by Luis Padron on 9/24/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

open class UIFloatingPromptTextField: UISafeTextField {
    
    open lazy var titleLabel = UILabel()
    open var titleText: String = "" { didSet { self.titleLabel.text = self.titleText.uppercased() } }
    open var titleTextColor: UIColor = UIColor.highlight { didSet { self.titleLabel.textColor = self.titleTextColor } }
    open var animationDuration: TimeInterval = 0.3
    open var titleTextSpacing: CGFloat = 0.0
    
    public var editingOrSelected : Bool {
        get {
            return self.isEditing || self.isSelected
        }
    }
    
    public required init(frame: CGRect, fieldType: FieldType, configuration: FieldConfiguration) {
        super.init(frame: frame, fieldType: fieldType, configuration: configuration)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        createTitleLabel()
        addObserverForTitle()
    }
    
    private func createTitleLabel() {
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.alpha = 0.0
        titleLabel.textColor = titleTextColor
        titleLabel.text = ""
        titleLabel.frame = titleLabelRectForBounds(bounds: bounds, editing: isTitleVisible())
        titleLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLabel)
    }
    
    private func addObserverForTitle() {
        addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
    }
    
    public func editingChanged() {
        updateTitleLabel(animated: true)
    }
    
    private func updateControl(animated: Bool = false) {
        updateTitleLabel(animated: animated)
    }
    
    private func updateTitleLabel(animated:Bool = false) {
        titleLabel.text = titleText.uppercased()
        titleLabel.textColor = titleTextColor
        updateTitleVisibility(animated: animated)
    }
    
    private var _titleVisible = false
    
    public func setTitleVisible(titleVisible:Bool, animated:Bool = false, animationCompletion: (()->())? = nil) {
        if(_titleVisible == titleVisible) {
            return
        }
        _titleVisible = titleVisible
        updateTitleVisibility(animated: animated, completion: animationCompletion)
    }
    
    public func isTitleVisible() -> Bool {
        return self.hasText || _titleVisible
    }
    
    private func updateTitleVisibility(animated:Bool = false, completion: (()->())? = nil) {
        let alpha: CGFloat = self.isTitleVisible() ? 1.0 : 0.0
        let frame: CGRect = self.titleLabelRectForBounds(bounds: self.bounds, editing: self.isTitleVisible())
        let updateBlock = { () -> Void in
            self.titleLabel.alpha = alpha
            self.titleLabel.frame = frame
        }
        
        if animated {
            let animationOptions:UIViewAnimationOptions = .curveEaseOut;
            let duration = animationDuration
            
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: { () -> Void in
                updateBlock()
                }, completion: { _ in
                    completion?()
            })
        } else {
            updateBlock()
            completion?()
        }
    }
    
    public var textHeight: CGFloat {
        get {
            return self.font!.lineHeight
        }
    }
    
    public var titleHeight: CGFloat {
        get {
            return titleLabel.font.lineHeight
        }
    }
    
    public func titleLabelRectForBounds(bounds:CGRect, editing:Bool) -> CGRect {
        var yForTitle = textHeight - titleHeight - titleTextSpacing
        if yForTitle < 0 { yForTitle = 0 }
        return CGRect(x: 0, y: yForTitle, width: bounds.width, height: titleHeight)
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: bounds.size.width, height: titleHeight)
        }
    }
}
