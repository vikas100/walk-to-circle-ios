//
//  WalkColors.swift
//
//  Created by Evgenii Neumerzhitckii on 26/12/2014.
//  Copyright (c) 2014 Evgenii Neumerzhitckii. All rights reserved.
//

import UIKit

enum WalkColors: String {
  case NewPinOverlay = "#A4AFFF33"
  case NewPinStroke = "#A4AFFF"

  case CurrentPinOverlay = "#99999933"
  case CurrentPinStroke = "#D5D5D5"

  static var ButtonTextColor: WalkColors {
    return NewPinStroke
  }
  
  var uiColor: UIColor {
    return iiUIColor.fromHexString(rawValue)
  }
}
