//
//  ScanBarcodeRouter.swift
//  MyFridge
//
//  Created by Lars Dahl on 01.06.2018.
//  Copyright (c) 2018 Lars Dahl. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol ScanBarcodeRoutingLogic
{
  //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol ScanBarcodeDataPassing
{
  var dataStore: ScanBarcodeDataStore? { get }
}

class ScanBarcodeRouter: NSObject, ScanBarcodeRoutingLogic, ScanBarcodeDataPassing
{
  weak var viewController: ScanBarcodeViewController?
  var dataStore: ScanBarcodeDataStore?
  
  // MARK: Routing
  
  //func routeToSomewhere(segue: UIStoryboardSegue?)
  //{
  //  if let segue = segue {
  //    let destinationVC = segue.destination as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //  } else {
  //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //    navigateToSomewhere(source: viewController!, destination: destinationVC)
  //  }
  //}

  // MARK: Navigation
  
  //func navigateToSomewhere(source: ScanBarcodeViewController, destination: SomewhereViewController)
  //{
  //  source.show(destination, sender: nil)
  //}
  
  // MARK: Passing data
  
  //func passDataToSomewhere(source: ScanBarcodeDataStore, destination: inout SomewhereDataStore)
  //{
  //  destination.name = source.name
  //}
}
