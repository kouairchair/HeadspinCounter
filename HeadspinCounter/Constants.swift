//
//  Constants.swift
//  HeadspinCounter
//
//  Created by headspinnerd on R 1/06/23.
//  Copyright © Reiwa 1 Koki. All rights reserved.
//

import Foundation

let serverUrl = "headspinnerd.tk"

func updateResCheck<T>(response: T) -> Bool {  // Must pass not optional type
    let string = "\(response)"
    if string.count > 12 {
        print("string.substring=\(string[...12])")
        if string[...12] == "Successfully" {
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}
