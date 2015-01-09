//
//  InitialMapZoom.swift
//
//  Class functions for loozing map at a specific location.
//
//  Created by Evgenii Neumerzhitckii on 12/10/2014.
//  Copyright (c) 2014 Evgenii Neumerzhitckii. All rights reserved.
//

import UIKit
import MapKit

private let iiMapSizeMeters:CLLocationDistance = WalkConstants.minCircleDistanceFromCurrentLocationMeters + WalkConstants.maxCircleDistanceFromCurrentLocationMeters

class InitialMapZoom {
  class func zoomToLocation(mapView: MKMapView, userLocation: MKUserLocation, animated: Bool) {
    let region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate,
      iiMapSizeMeters, iiMapSizeMeters)

    mapView.setRegion(region, animated:animated)
  }

  class func needZoomingBeforePlay(mapView: MKMapView) -> Bool {
    return !(isZoomLevelOk(mapView.visibleMapRect) && mapView.userLocationVisible)
  }

  // Zooms map to user location. It is called once after the app has started.
  class func zoomToInitialLocation(mapView: MKMapView, onZoomFinished: ()->()) {
    InitialMapZoom.zoomToLocation(mapView, userLocation: mapView.userLocation, animated: false)

    if WalkTutorial.showTutorial {
      showYouAreHereAnnotation(mapView, onZoomFinished: onZoomFinished)
    } else {
      // Send "Zoom finished" after a delay. It allows to show start button animation is visible
      // after view controller transition animation.
      iiQ.runAfterDelay(WalkConstants.showMapAnnotationAfterDelay) {
        onZoomFinished()
      }
    }
  }

  private class func showYouAreHereAnnotation(mapView: MKMapView, onZoomFinished: ()->()) {
    mapView.userLocation.title = NSLocalizedString("You are here",
      comment: "Short message shown above user location on the map")

    Annotation.showCalloutAfterDelay(mapView, annotation: mapView.userLocation,
      delay: WalkConstants.showMapAnnotationAfterDelay) {

      Annotation.hideCalloutAfterDelay(mapView,
        annotation: mapView.userLocation, delay: WalkConstants.hideMapAnnotationAfterDelay)

      onZoomFinished()
    }
  }

  private class func isZoomLevelOk(mapRect: MKMapRect) -> Bool {
    let mapSize = iiGeo.mapSizeInMeters(mapRect)
    let minSize = min(mapSize.width, mapSize.height)

    // Zoom level is ok if it less than two times bigger or more than two times smaller
    // than initial zoom size.
    return minSize < CGFloat(iiMapSizeMeters * 2)
      && minSize > CGFloat(iiMapSizeMeters / 2)
  }

  // Scroll/zooms map to user location if it is not visible
  class func makeUserLocationVisible(mapView: MKMapView) {
    if mapView.userLocationVisible { return }

    InitialMapZoom.zoomToLocation(mapView, userLocation: mapView.userLocation, animated: true)
  }
}