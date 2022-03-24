import Foundation

public func totalTime(_ chrono: Chrono) -> Double {
    if let start = chrono.start {
        return Date().timeIntervalSince(start) + chrono.time
    }
    return chrono.time
}

public func totalTime(_ category: Category) -> Double {
    var total: Double = 0
    if let timersList = category.chronos {
        timersList.enumerateObjects { (elem, _, _) -> Void in
            total += totalTime(elem as! Chrono)
        }
    }
    return total
}
