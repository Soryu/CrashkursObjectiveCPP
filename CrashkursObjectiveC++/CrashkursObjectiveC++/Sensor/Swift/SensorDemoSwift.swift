//
//  SensorDemoSwift.swift
//  CrashkursObjectiveC++
//
//  Created by Stanley Rost on 03.11.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

import Foundation

@objc class SensorDemoSwift: COCSensorDemo {
  
  var readings:Array<SensorReading>
  
  override init() {
    readings = []
    super.init()
  }
  
  override func run() {
    
    self.creationTime = self.executionTimeOfBlock {
      self.createReadings()
    }
    
    self.lookupTime = self.executionTimeOfBlock {
      self.lookupValues()
    }
  }
  
  func createReadings() {
    self.removeAllReadings()
    
    let count = self.numberOfBatches / 2
    for (var index:UInt = 0; index < count; ++index) {
      self.appendBatchOfSensorReadings()
      self.prependBatchOfSensorReadings()
    }
  }
  
  func lookupValues() {
    let earliest = self.earliestTime()
    let latest   = self.latestTime()
    let duration = latest - earliest
    
    let count = self.numberOfLookups
    for (var index:UInt = 0; index < count; ++index) {
      let randomOffset = arc4random() % UInt32(duration)
      let sampleTime = earliest + Double(randomOffset)
      self.interpolatedValueAtTime(sampleTime)
    }
  }
  
  override func removeAllReadings() {
    readings.removeAll(keepCapacity: false)
  }
  
  func defaultTime() -> NSTimeInterval {
    return NSDate.timeIntervalSinceReferenceDate()
  }
  
  func earliestTime() -> NSTimeInterval {
    if let reading = self.readings.first {
      return reading.time
    } else {
      return self.defaultTime()
    }
  }
  
  func latestTime() -> NSTimeInterval {
    if let reading = self.readings.last {
      return reading.time
    } else {
      return self.defaultTime()
    }
  }
  
  override func appendBatchOfSensorReadings() {
    SensorDemoSwift.provideRandomValues(Int(self.batchSize), startTime: self.latestTime()) {
      time, value, sensorId in
      
      self.readings.append(SensorReading(time: time, value: value, sensorId: sensorId))
    }
  }
  
  override func prependBatchOfSensorReadings() {
    
    var newValues = Array<SensorReading>()
    SensorDemoSwift.provideRandomValues(-Int(self.batchSize), startTime: self.earliestTime()) {
      time, value, sensorId in
      
      newValues.append(SensorReading(time: time, value: value, sensorId: sensorId))
    }
    
    var newOrderedValues = newValues.reverse()
    newOrderedValues.extend(self.readings)
    
    self.readings = newOrderedValues
  }
  
  override func interpolatedValueAtTime(time: NSTimeInterval) -> Double {
    let range = Range(start: 0, end: countElements(self.readings))
    let index = self.insertionIndexOfReadingForTime(time, range: range);
    
    if index == 0 {
      return self.readings.first!.value
    } else if index == countElements(self.readings) {
      return self.readings.last!.value
    } else {
      return self.readings[index - 1].interpolatedValueAtTime(time, betweenReceiverAndReading:self.readings[index])
    }
  }
  
  // binary search
  func insertionIndexOfReadingForTime(time: NSTimeInterval, range: Range<Int>) -> Int {
    
    if countElements(range) == 1 {
      if (time <= self.readings[range.startIndex].time)
      {
        return range.startIndex
      }
      else
      {
        return range.startIndex + 1
      }
    }
    
    let length = countElements(range)
    
    let middleIndex = range.startIndex + length / 2
    let middleTime = self.readings[middleIndex].time
    
    if (time <= middleTime) {
      let newRange = Range(start:range.startIndex, end:range.startIndex + length / 2)
      return self.insertionIndexOfReadingForTime(time, range: newRange)
    } else {
      let newRange = Range(start:range.startIndex + length / 2, end:range.endIndex)
      return self.insertionIndexOfReadingForTime(time, range: newRange)
    }
  }
  
  //  class func provideRandomValues(countAndDirection: Int, startTime: NSTimeInterval, usingStorage storage:(iTime: NSTimeInterval, iValue: Double, iSensorId: NSUUID) -> Void) {
  //
  //    // assert(storage != nil)
  //
  //    var time = startTime;
  //    let count = abs(countAndDirection)
  //    let backwards = countAndDirection < 0
  //
  //    let sensorID = NSUUID()
  //
  //    for _ in 1 ..< count {
  //      let timeDelta = arc4random() % 3600
  //
  //      if backwards {
  //        time -= Double(timeDelta)
  //      } else {
  //        time += Double(timeDelta)
  //      }
  //
  //      let value = arc4random() % 100
  //      storage(iTime: time, iValue: Double(value), iSensorId: sensorID)
  //    }
  //  }
  
}
