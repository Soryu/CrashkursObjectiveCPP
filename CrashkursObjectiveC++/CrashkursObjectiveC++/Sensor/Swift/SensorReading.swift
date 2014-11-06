//
//  SensorReading.swift
//  CrashkursObjectiveC++
//
//  Created by Stanley Rost on 03.11.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

import Foundation

struct SensorReading {
  let time: NSTimeInterval
  let value: Double
  let sensorId: NSUUID
  
  func interpolatedValueAtTime(interpolationTime :NSTimeInterval, betweenReceiverAndReading nextReading: SensorReading) -> Double {
    
    assert(self.time <= interpolationTime)
    assert(nextReading.time >= interpolationTime);
    
    let timeA = self.time
    let timeB = nextReading.time
    let valueA = self.value
    let valueB = nextReading.value
    
    return valueA + (valueB - valueA) * (interpolationTime - timeA) / (timeB - timeA);
  }
}
