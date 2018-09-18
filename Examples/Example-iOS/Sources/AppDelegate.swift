import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        let navigationController = UINavigationController(rootViewController: HomeViewController())
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
