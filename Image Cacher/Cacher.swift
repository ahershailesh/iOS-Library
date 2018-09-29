//
//  Cacher.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/16/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//

import CoreData

fileprivate final class CacherCoreData {
    static let shared = CacherCoreData()
    private var container = NSPersistentContainer(name: "Cacher")
    init() {
        container.loadPersistentStores { (storeDescription, error) in
            print(storeDescription)
        }
    }
    var context : NSManagedObjectContext {
        return container.viewContext
    }
}


public class ImageCacher : NetworkHTTPCall {
    
    public typealias Completion = (_ image: Image?) -> Void
    public typealias APISuccess = (_ success: Bool) -> Void
    
    //MARK:- Public Methods
    /// it will retrieve data from url and store it in cache. cache is managed by coredata.
    ///
    /// - Parameters:
    ///   - url: link from where profile pic is to be fetched.
    ///   - callBack: call back on retrieval.
    public func get(from url: URL, callBack: Completion?) {
        
        // First search URL in cache
        getImageDataFromCache(for: url) { [weak self] image in
            guard let image = image else {
                // If URL not found in cache. Hit URL and save data to cache along with URL
                self?.getImageFromServer(for: url) { image in
                    callBack?(image)
                }
                return
            }
            callBack?(image)
        }
    }
    
    //MARK:- Private Methods
    private func getImageDataFromCache(for url: URL, completion: Completion?) {
        let request = NSFetchRequest<Image>(entityName: "Image")
        request.predicate = NSPredicate(format: "url = %@", argumentArray: [url.absoluteString])
        
        let context = CacherCoreData.shared.context
        var image : Image?
        do {
            let objects = try context.fetch(request)
            if !objects.isEmpty {
                image = objects.first
            }
        } catch {
            print(error.localizedDescription)
        }
        
        if let image = image {
            // Validate staleness of the image. If image is stale don't return it.
            validateStaleness(of: image) { success in
                let image = success ? image : nil
                completion?(image)
            }
        } else {
            completion?(nil)
        }
    }
    
    private func validateStaleness(of image: Image, callBack: APISuccess?) {
        guard let url = image.url else { callBack?(false); return }
        getHeaders(from: url) { (success, response, _) in
            var success = false
            if let date = response?.lastModified, image.updatesDateTime?.isEqual(to: date) ?? false {
                 success = true
            }
            callBack?(success)
        }
    }
    
    private func getImageFromServer(for url: URL, completion: Completion?) {
        getAPIResponse(for: url) { [weak self] (success, response, _) in
            var image: Image?
            if let data = response?.data,
                !data.isEmpty,
                let lastUpdate = response?.lastModified {
                image = self?.saveImageDataToCache(data: data, url: url, lastUpdate: lastUpdate)
            }
            completion?(image)
        }
    }
    
    /// This method will be saving image to cache and returning Image object. Even when image does not get saved to cache method will be returning Image.
    ///
    /// - Parameters:
    ///   - data: Image data
    ///   - url: Server url
    ///   - lastUpdate: Last updated date, getting from server.
    /// - Returns: Image object
    private func saveImageDataToCache(data: Data, url: URL, lastUpdate: Date) -> Image {
        let context = CacherCoreData.shared.context
        let image = Image(context: context)
        image.url = url
        image.data = data as NSData
        image.updatesDateTime = lastUpdate as NSDate
        save(context: context)
        return image
    }
    
    private func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("unable to save context \(error.localizedDescription)")
            }
        }
    }
}
