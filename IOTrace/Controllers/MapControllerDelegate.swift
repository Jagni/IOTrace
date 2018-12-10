//
//  MapControllerDelegate.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 10/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

protocol MapControllerDelegate {
    func didSelectMarker(location: LocationEvent)
}
