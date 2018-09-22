//
//  Image+CoreDataProperties.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/16/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var url: URL?
    @NSManaged public var updatesDateTime: NSDate?

}
