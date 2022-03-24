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

public func secondsToString(TimeInSeconds inputTime: Double) -> String {
    
    let time: Int = Int(inputTime)
    
    var heure = ""
    var minute = ""
    var seconds = ""
    
    if((time / 3600) < 10){
        heure = "0" + String(time / 3600)
    }
    else{
        heure = String(time / 3600)
    }
    
    let rst: Int = Int(time) % 3600
    
    if((rst / 60) < 10){
        minute = "0" + String(rst / 60)
    }
    else{
        minute = String(rst / 60)
    }
    
    if((rst % 60) < 10){
        seconds = "0" + String(rst % 60)
    } else {
        seconds = String(rst % 60)
    }
    
    return "\(heure):\(minute):\(seconds)"
}
