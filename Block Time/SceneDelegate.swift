//
//  SceneDelegate.swift
//  Block Time
//
//  Created by Julia Yu on 3/5/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let calendarViewController = CalendarDayViewController()
        let navigationController = UINavigationController(rootViewController: calendarViewController)
        
        window?.rootViewController = LaunchScreenViewController()
        window?.makeKeyAndVisible()
    }
}
