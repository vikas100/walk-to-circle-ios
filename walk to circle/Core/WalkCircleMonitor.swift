import UIKit
import CoreLocation

private let walkCircleMonitor = WalkCircleMonitor()

class WalkCircleMonitor: NSObject {
  private var region = CLCircularRegion()
  
  // Used to send update of location to the Apple Watch app
  var didReceiveLocationUpdateForWatch: (()->())?
  
  class var shared: WalkCircleMonitor {
    return walkCircleMonitor
  }

  override private init() {
    super.init()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
  }

  func applicationWillEnterForeground(notification: NSNotification) {
    // We need to restart monitoring in case it was stopped
    WalkCircleMonitor.start()
  }

  class func start() {
    if let currentCoordinate = WalkCoordinate.current {
      shared.start(currentCoordinate)
    }
  }

  private func start(coordinate: CLLocationCoordinate2D) {
    region = WalkCircleMonitor.createRegion(coordinate)
    WalkLocation.shared.startUpdatingLocation()
  }

  class func stop() {
    WalkLocation.shared.stopUpdatingLocation()
  }

  func processLocationUpdate(location: CLLocation) -> Bool {
    didReceiveLocationUpdateForWatch?()
    
    if region.containsCoordinate(location.coordinate) {
      locationReached()
      return true
    }

    return false
  }

  private func locationReached() {
    WalkCoordinate.clearCurrent()
    WalkCircleMonitor.stop()
    WalkUserDefaults.anyCircleReached.save(true)
    WalkCirlesReachedToday.increment()
    WalkNotification.showNow("You reached your circle. Well done!")
    WalkViewControllers.Congrats.show()
  }

  private class func createRegion(coordinate: CLLocationCoordinate2D) -> CLCircularRegion {
    return CLCircularRegion(center: coordinate, radius: WalkConstants.regionCircleRadiusMeters,
      identifier: "walk circle")
  }
}
