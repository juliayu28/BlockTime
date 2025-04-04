//
//  AppDelegate.swift
//  Block Time
//
//  Created by Julia Yu on 3/5/25.
//

import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Get the client ID from Info.plist
            guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
                print("Error: GIDClientID not found in Info.plist")
                return true
            }
            
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(
                clientID: clientID
            )
            
            return true
        }
        
        // Handles the URL that the app receives at the end of the authentication process
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            return GIDSignIn.sharedInstance.handle(url)
        }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
}
