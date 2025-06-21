//
//  SceneDelegate.swift
//  Lab9
//
//  Created by Елизавета Сенюк on 19.06.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
#if DEBUG
        if CommandLine.arguments.contains("-UITests") {
            let mainVC = MainMenuViewController()
            window.rootViewController = UINavigationController(rootViewController: mainVC)
            self.window = window
            window.makeKeyAndVisible()
            return
        }
#endif
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        window.rootViewController = loginVC
        self.window = window
        window.makeKeyAndVisible()
    }
}
