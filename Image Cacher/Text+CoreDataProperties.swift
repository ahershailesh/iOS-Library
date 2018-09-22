//
//  Text+CoreDataProperties.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/16/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//
//

import Foundation
import CoreData


extension Text {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Text> {
        return NSFetchRequest<Text>(entityName: "Text")
    }

    @NSManaged public var text: String?
    @NSManaged public var tag: String?
    @NSManaged public var updatedDateTime: String?

}
