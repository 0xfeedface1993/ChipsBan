//
//  AppDelegate.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/1/28.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import UIKit
import CoreData
import CryptoKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        print("abcdefghijklmnopqrst".md5Hex)
//        print(safeAdd(x: 0xabcd, y: 0xff0c))
//        print(bitRotate(number: 0xaaaa, bits: 4))
//        print(md5CMN(q: 1, a: 2, b: 3, x: -4, s: 5, t: -6))
//        print(safeAdd(x: -4, y: -6))
//        print(bitRotate(number: -7, bits: 5))
        // 6aa8de45918023095f6e831efe48d00b
        
//        let md5 = Insecure.MD5.hash(data: "xts@19931022".data(using: .utf8)!)
//        // 12c3901594b3affdf0e98fa8ffce6c1d
//        print(md5)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }


    lazy var persistentor : NSPersistentContainer = {
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
}

