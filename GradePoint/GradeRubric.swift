//
//  GradeRubric.swift
//  GradePoint
//
//  Created by Luis Padron on 5/14/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

/**
 Defines a Grade rubric object which is a container of `GradePercentage` objects.
 Only one of these shall exist per application.
 */
class GradeRubric: Object {
    /// The shared GradeRubric for the entire application
    public static var shared: GradeRubric {
        guard let rubric = DatabaseManager.shared.realm.object(ofType: GradeRubric.self, forPrimaryKey: 1) else {
            fatalError("Unable to get shared GradeRubric with primary key of 1")
        }
        return rubric
    }

    // MARK: Properties

    @objc dynamic var id: Int = 1
    var percentages = List<GradePercentage>()

    // MARK: Realm

    override class func primaryKey() -> String {
        return "id"
    }

    // MARK: API

    /// Creates a default rubric, if one already exists, wipes it and replaces it with this one.
    public static func createRubric(type: GPAScaleType) {
        let realm = try! Realm()

        if realm.objects(GradeRubric.self).count > 0 {
            DatabaseManager.shared.deleteObjects(realm.objects(GradeRubric.self))
            DatabaseManager.shared.deleteObjects(realm.objects(GradePercentage.self))
        }

        let rubric = GradeRubric()
        let percentages = List<GradePercentage>()

        switch type {
        case .plusScale:
            let scale = kPlusScaleGradeLetterRanges
                .enumerated()
                .map { GradePercentage(lower: $1.lowerBound, upper: $1.upperBound, grade: kPlusScaleLetterGrades[$0]) }
            percentages.append(objectsIn: scale)

        case .nonPlusScale:
            let scale = kGradeLetterRanges
                .enumerated()
                .map { GradePercentage(lower: $1.lowerBound, upper: $1.upperBound, grade: kLetterGrades[$0]) }
            percentages.append(objectsIn: scale)
        }

        rubric.percentages = percentages

        DatabaseManager.shared.createObject(GradeRubric.self, value: rubric, update: true)
    }

    /// Returns the letter grade for the given percentage score, if possible, other wise returns `nil`
    public func letterGrade(for score: Double) -> String? {
        for percent in self.percentages {
            if percent.isInRange(score) { return percent.letterGrade }
        }
        return nil
    }

    /// Returns the percentage of for the requested GradePercentage, either lower/upper bound
    public func percentage(for index: Int, type: GradePercentage.PercentageType) -> Double {
        switch type {
        case .lowerBound:
            return self.percentages[index].lowerBound
        case .upperBound:
            return self.percentages[index].upperBound
        }
    }
}
