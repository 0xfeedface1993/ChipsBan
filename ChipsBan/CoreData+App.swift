//
//  CoreData+App.swift
//  ChipsBan
//
//  Created by holybeta on 2020/6/28.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataCore {
    static let share = CoreDataCore()
    
    lazy var persistentor : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Ban")
        let storeURL = URL.storeURL(for: "group.s8.share", databaseName: "Ban")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print(storeDescription)
        })
        return container
    }()
    
    func saveContext() {
        if persistentor.viewContext.hasChanges {
            do {
                try persistentor.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private lazy var prevPersistentor : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Ban")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print(storeDescription)
        })
        return container
    }()
    
    func copyPreviewsRecords() {
        let context = CoreDataCore.share.prevPersistentor.viewContext
        let fetch = NSFetchRequest<Check>(entityName: "Check")
        fetch.predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor.init(key: "time", ascending: false)
        fetch.sortDescriptors = [sort]
        do {
            let results = try context.fetch(fetch)
            
            let fetchNewResults = NSFetchRequest<Check>(entityName: "Check")
            fetchNewResults.predicate = NSPredicate(value: true)
            fetchNewResults.sortDescriptors = [sort]
            
            let next = CoreDataCore.share.persistentor.viewContext
            let newResults = try next.fetch(fetchNewResults)
            guard results.count > 0 else {
                print(">>> 无历史记录，不复制")
                return
            }
            let all = results.filter({ t in !newResults.contains { c in c.account == t.account && c.time == t.time } }).compactMap({ $0.dictionary })
            guard let entity = NSEntityDescription.entity(forEntityName: "Check", in: next) else {
                print(">>> NSEntityDescription初始化失败")
                return
            }
            let batchRequest = NSBatchInsertRequest(entity: entity, objects: all)
            print(">>> 复制\(all.count)项数据")
            try next.execute(batchRequest)
            try next.save()
            let deleteRequest = NSBatchDeleteRequest(objectIDs: results.map({ $0.objectID }))
            print(">>> 删除原始\(results.count)项数据")
            try context.execute(deleteRequest)
            CoreDataCore.share.saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension URL {
    static func storeURL(for appGroupName: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName) else {
            fatalError("Shared file container could not be created")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

extension Check {
    var dictionary: [String:Any]? {
        guard let a = account, let p = password, let t = time else {
            return nil
        }
        return ["account": a, "password": p, "time": t]
    }
}
