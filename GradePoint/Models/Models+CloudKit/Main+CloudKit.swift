//
//  Main+CloudKit.swift
//  GradePoint
//
//  Created by Luis on 5/14/19.
//  Copyright © 2019 Luis Padron. All rights reserved.
//

import IceCream

// MARK: Class

extension Class: CKRecordConvertible { }
extension Class: CKRecordRecoverable { }

// MARK: Assignment

extension Assignment: CKRecordConvertible { }
extension Assignment: CKRecordRecoverable { }
