import UIKit
import CoreData

class ChronoCell: UITableViewCell {
    @IBOutlet weak var _title: UILabel!
    @IBOutlet weak var _time: UILabel!
    
    @IBOutlet weak var _button: UIButton!
    
    var _chrono: Chrono!
    var _status: Bool!
    var _context:  NSManagedObjectContext!
    var _timer: Timer!
    
    func initisialize() {
        if (self._chrono.start == .none || self._chrono.start == nil) {
            self._status = true
            self._button.setTitle("Play", for: .normal)
        } else {
            self._status = false
            self._button.setTitle("Stop", for: .normal)
            self._timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func touched() {
        if self._status {
            self.play()
        } else {
            self.stop()
        }
    }
    
    private func play() {
        self._chrono.start = Date()
        do {
            try self._context.save()
            print("Chrono start saved")
        } catch {
            print("Can't save: \(error)")
        }
        
        self._timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        self._button.setTitle("Stop", for: .normal)
        self._status = false
    }
    
    @objc private func update() {
        print("Update chrono '\(self._chrono.name ?? "")'")
        
        if self._chrono.name == nil {
            print("Killing chrono")
            self._timer.invalidate()
        }
        
        let t = totalTime(self._chrono)
        self._time.text = secondsToString(TimeInSeconds: t)
    }
    
    private func stop() {
        let difference = Date().timeIntervalSince(self._chrono.start!)
        self._chrono.time += difference
        self._chrono.start = nil
        
        do {
            try self._context.save()
            print("Chrono stop saved")
        } catch {
            print("Can't saved: \(error)")
        }
        
        self._timer.invalidate()
        
        self._button.setTitle("Play", for: .normal)
        self._status = true
    }
}
