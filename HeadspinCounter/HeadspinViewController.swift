//
//  ViewController.swift
//  HeadspinCounter
//
//  Created by headspinnerd on R 1/06/23.
//  Copyright © Reiwa 1 Koki. All rights reserved.
//

import UIKit
import CoreMotion

class HeadspinViewController: UIViewController {

    // https://developer.apple.com/documentation/coremotion/getting_raw_accelerometer_events
    
    var timer: Timer?
    @IBOutlet var xLabel: UILabel!
    @IBOutlet var yLabel: UILabel!
    @IBOutlet var zLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var recordLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    var startFlag: Bool = false
    var lastX: Int? = nil
    var lastY: Int? = nil
    var lastZ: Int? = nil
    var totalX: Int = 0
    var totalY: Int = 0
    var totalZ: Int32 = 0
    var topRecord: Double = 0
    var counter = 0.00
    var startTime = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDeviceMotion()
        updateCount()
    }
    
    let motion = CMMotionManager()
    
    func startDeviceMotion() {
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 100.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the motion data.
            self.timer = Timer(fire: Date(), interval: (1.0 / 100.0), repeats: true,
               block: { (timer) in
                if let data = self.motion.deviceMotion {
                    if self.startFlag == false {
                        return
                    }
                    
                    func convertToAngle(value: Double) -> Int {
                        // 小数点第２位まで切り捨てる
                        let decimal2nd = floor(value * 100) / 100
                        // 0~359度にconvert
                        let degree = (decimal2nd + 3) * 60
                        return Int(degree)
                    }
                    
                    func calcDiff(lastVal: Int, curVal: Int) -> Int {
                        var diff = lastVal - curVal
                        if diff > 180
                        {
                            diff -= 360
                        }
                        else if diff < -180
                        {
                            diff += 360
                        }
                        return diff
                    }
                    
                    // Get the attitude relative to the magnetic north reference frame.
                    let x = convertToAngle(value: data.attitude.pitch)
                    let y = convertToAngle(value: data.attitude.roll)
                    let z = convertToAngle(value: data.attitude.yaw)
                    
                    // For headspin, only z-axis should be drastically changed.
                    // ( z-axis change need to be over 360 degree within 1 second and
                    //   x-axis and y-axis change need to be +-10 degree within 1 second
                    // The device orientation need to be landscape left or right during headspin
                    if let _lastX = self.lastX, let _lastY = self.lastY, let _lastZ = self.lastZ {
                        self.totalX += calcDiff(lastVal: _lastX, curVal: x)
                        self.totalY += calcDiff(lastVal: _lastY, curVal: y)
                        self.totalZ += Int32(calcDiff(lastVal: _lastZ, curVal: z))
                    }

                    self.xLabel.text = String(format:"x: %d°", x)
                    self.yLabel.text = String(format:"y: %d°", y)
                    self.zLabel.text = String(format:"z: %d°", z)
                    let totalRound = Double(abs(self.totalZ)) / Double(365)
                    // 小数点第1位まで切り捨てる
                    let decimalRound = abs(floor(totalRound * 10) / 10)
                    self.totalLabel.text = String(format:"%.1f rounds", decimalRound)
                    if self.topRecord < decimalRound {
                        self.topRecord = decimalRound
                        let roundPerSecond: Double = decimalRound / (self.counter - self.startTime)
                        self.recordLabel.text = String(format:"%.1f rounds(%.2fr/sec)", decimalRound, roundPerSecond)
                    }
                    self.counter += 1.0 / 100.0
                    self.timeLabel.text = String(format:"%.2f", self.counter)
                    if (abs(self.totalX) > 20) || (abs(self.totalY) > 20) {
                        self.totalX = 0
                        self.totalY = 0
                        self.totalZ = 0
                        self.startTime = self.counter
                    }
                    self.lastX = x
                    self.lastY = y
                    self.lastZ = z
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
        }
    }
    
    @IBAction func startAction(_ sender: UIButton) {
        if startFlag == false {
            sender.setTitle("Stop", for: .normal)
            startFlag = true
            resetValues()
        }
        else {
            sender.setTitle("Start", for: .normal)
            startFlag = false
        }
    }
    
    func resetValues() {
        lastX = nil
        lastY = nil
        lastZ = nil
        totalZ = 0
        counter = 0.00
        startTime = 0.00
        xLabel.text = "x: -"
        yLabel.text = "y: -"
        zLabel.text = "z: -"
        totalLabel.text = "0 round"
        timeLabel.text = ""
    }
    
    func updateCount() {
        let url = "http://\(serverUrl)/HeadspinCountApp/updateCount.php"
        let post = ""
        let parsedData: String? = HttpRequest().sendPostRequestSync2(urlString: url, post: post)
        print("parseData=\(String(describing: parsedData))")
        if let _parsedData = parsedData {
            if updateResCheck(response: _parsedData) {
            } else {
                print("Update failed")
            }
        } else {
            print("Update failed / nil error")
        }
    }
}

