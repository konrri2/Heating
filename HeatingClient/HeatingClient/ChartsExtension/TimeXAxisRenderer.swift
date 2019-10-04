//
//  TimeXAxisRenderer.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 04/10/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation
import Charts


class TimeXAxisRenderer: XAxisRenderer {
    override func computeAxisValues(min: Double, max: Double)
    {
        guard let axis = self.axis else { return }
        
        let yMin = min
        let yMax = max
        
        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)
        
        if labelCount == 0 || range <= 0 || range.isInfinite
        {
            axis.entries = [Double]()
            axis.centeredEntries = [Double]()
            return
        }
        
        // Find out how much spacing (in y value space) between axis values
        let rawInterval = range / Double(labelCount)
        var interval = 3600.0
        
        // Normalize interval
        let intervalMagnitude = pow(10.0, Double(Int(log10(interval)))).roundedToNextSignficant()
        let intervalSigDigit = Int(interval / intervalMagnitude)
        if intervalSigDigit > 5
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            // if it's 0.0 after floor(), we use the old value
            interval = floor(10.0 * intervalMagnitude) == 0.0 ? interval : floor(10.0 * intervalMagnitude)
        }
        
        var n = axis.centerAxisLabelsEnabled ? 1 : 0
        
        // force label count
        if axis.isForceLabelsEnabled
        {
            interval = Double(range) / Double(labelCount - 1)
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var v = yMin
            
            for _ in 0 ..< labelCount
            {
                axis.entries.append(v)
                v += interval
            }
            
            n = labelCount
        }
        else
        {
            // no forced count
            
            var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval
            
            if axis.centerAxisLabelsEnabled
            {
                first -= interval
            }
            
            let last = interval == 0.0 ? 0.0 : (floor(yMax / interval) * interval).nextUp
            
            if interval != 0.0 && last != first
            {
                for _ in stride(from: first, through: last, by: interval)
                {
                    n += 1
                }
            }
            else if last == first && n == 0
            {
                n = 1
            }
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var f = first
            var i = 0
            while i < n
            {
                if f == 0.0
                {
                    // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    f = 0.0
                }
                
                axis.entries.append(Double(f))
                
                f += interval
                i += 1
            }
        }
        
        // set decimals
        if interval < 1
        {
            axis.decimals = Int(ceil(-log10(interval)))
        }
        else
        {
            axis.decimals = 0
        }
        
        if axis.centerAxisLabelsEnabled
        {
            axis.centeredEntries.reserveCapacity(n)
            axis.centeredEntries.removeAll()
            
            let offset: Double = interval / 2.0
            
            for i in 0 ..< n
            {
                axis.centeredEntries.append(axis.entries[i] + offset)
            }
        }
    }
}
