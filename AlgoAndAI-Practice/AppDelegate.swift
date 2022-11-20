//
//  AppDelegate.swift
//  AlgoAndAI-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var rootController: UINavigationController {
        guard let window = window, let root = window.rootViewController as? UINavigationController else { fatalError() }
        return root
    }
    
    private lazy var appCoordinator = AppCoordinator(router: RouterImp(rootController: rootController),
                                                     facotry: CoordinatorFactoryImp())

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController()
        window?.makeKeyAndVisible()
        
        appCoordinator.start()
        
        return true
    }
}

