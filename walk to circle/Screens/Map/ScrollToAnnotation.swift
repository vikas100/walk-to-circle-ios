import UIKit
import MapKit

class ScrollToAnnotation {
  // Returns the scroll amount (in view coordinates) to make the annotation visible
  class func getScroll(mapSize: CGSize, annotationCoordinate: CGPoint) -> CGSize {

    var scroll = CGSize(width: 0, height: 0)
    let margin:CGFloat = 50 // additional scroll amount to show gap between annotation and screen edge
    let topMargin:CGFloat = 125

    if annotationCoordinate.x > (mapSize.width - margin)  {
      scroll.width = annotationCoordinate.x - mapSize.width + margin
    } else if annotationCoordinate.x < margin {
      scroll.width = annotationCoordinate.x - margin
    }

    if annotationCoordinate.y > (mapSize.height - margin)  {
      scroll.height = annotationCoordinate.y - mapSize.height + margin
    } else if annotationCoordinate.y < topMargin {
      scroll.height = annotationCoordinate.y - topMargin
    }

    return scroll
  }

  // converts distance (in pixels) in UIView to coordinate span (latitude and longitude)
  class func convertDistance(distance: CGSize,
    toCoordinateSpanForMapView mapView: MKMapView) -> MKCoordinateSpan {

    let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: distance)
    let region = mapView.convertRect(rect, toRegionFromView: mapView)

    var latitudeDelta = region.span.latitudeDelta
    if distance.height > 0 { latitudeDelta *= -1 }

    var longitudeDelta = region.span.longitudeDelta
    if distance.width < 0 { longitudeDelta *= -1 }

    return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
  }

  // Make sure annotation and its callout view is fully visible.
  // Return the amount of scolling needed
  // in order to display annotation and its callout.
  class func scrollNeededToSeeAnnotation(mapView: MKMapView, startButton: UIView,
    willDropAt coordinate: CLLocationCoordinate2D) -> CGSize {

    let coordinateInView = mapView.convertCoordinate(coordinate, toPointToView: mapView)

    let scrollDelta = ScrollToAnnotation.getScroll(mapView.frame.size,
      annotationCoordinate: coordinateInView)

    let userLocationInView =  mapView.convertCoordinate(mapView.userLocation.coordinate,
      toPointToView: mapView)

    let scollToRightOnHorizontalCorrection = userLocationInView.x < coordinateInView.x

    // Make sure annotation does not overlap with the button
    return ButtonOverlap().scollCorrection(scrollDelta,
      buttonRect: startButton.frame, pinCoordinate: coordinateInView,
      scrollToRightOnHorizontalCorrection: scollToRightOnHorizontalCorrection)
  }

  // Scroll map view by given amount
  class func scrollMap(scollBy: CGSize, mapView: MKMapView, onFinishedScrolling: ()->()) {

    if scollBy.width == 0 && scollBy.height == 0 { // no need to scroll
      onFinishedScrolling()
      return
    }

    // convert scroll amount from pixels to map coordinates
    let coordinateSpan = ScrollToAnnotation.convertDistance(scollBy,
      toCoordinateSpanForMapView: mapView)

    let newCenter = CLLocationCoordinate2D(
      latitude: mapView.region.center.latitude + coordinateSpan.latitudeDelta,
      longitude: mapView.region.center.longitude + coordinateSpan.longitudeDelta)

    UIView.animateWithDuration(0.2,
      animations: {
        mapView.region.center = newCenter
      },
      completion: { finished in
        onFinishedScrolling()
      }
    )
  }
}

