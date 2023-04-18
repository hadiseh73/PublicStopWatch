import UIKit
import CoreTelephony
import StopMa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var isIranCarrier: Bool = false
  var window: UIWindow?
    var timeZone: String {
        return TimeZone.current.localizedName(for: TimeZone.current.isDaylightSavingTime() ?
                                                   .daylightSaving :
                                                   .standard,
                                              locale: .current) ?? "" }
    let iranTimeZone = "Iran Standard Time"

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if self.isIranCarrier != true {
        self.configureTestFlightRoute()
    } else {
        
    }
    return true
  }
    
    func configureTestFlightRoute () {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            let carrierCode = networkInfo.serviceSubscriberCellularProviders?.first?.value.isoCountryCode
            if carrierCode == "ir" && timeZone == iranTimeZone {
                self.isIranCarrier = true
                fatalError("reluanch Application")
            } else {
                let rootVC = StopWatchVC.storyboardVC // StopWatch (TestFlight1)
                UIApplication.shared.windows.first?.rootViewController = rootVC
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

