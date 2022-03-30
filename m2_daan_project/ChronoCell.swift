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
    
    // Function must be manually called when creating the cell
    func initisialize() {
        // Retrieve the state of the timer, depending on the presence or not of a starting date
        if (self._chrono.start == .none || self._chrono.start == nil) {
            self._status = true
            self._button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            self._button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            self._status = false
            self._timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
    }
    
    // Function called on button click
    @IBAction func touched() {
        if self._status {
            self.play()
        } else {
            self.stop()
        }
    }
    
    // Function to start a timer
    private func play() {
        // Save the current time
        self._chrono.start = Date()
        do {
            // Save in CoreData
            try self._context.save()
            print("Chrono start saved")
        } catch {
            print("Can't save: \(error)")
        }
        
        // Launch the Timer to update display
        self._timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        // Update button image
        self._button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        self._status = false
    }
    
    // Function called to update display
    @objc private func update() {
//        print("Update chrono '\(self._chrono.name ?? "")'")
        
        if self._chrono.name == nil || self._chrono == .none {
//            print("Killing chrono")
            self._timer.invalidate()
        }
        
        // Fetch total time
        let t = totalTime(self._chrono)
        // Convert to string & update display
        self._time.text = secondsToString(TimeInSeconds: t)
    }
    
    // Function to stop a chrono
    private func stop() {
        // Compute the elapsed time
        let difference = Date().timeIntervalSince(self._chrono.start!)
        // Add to the total
        self._chrono.time += difference
        // Reset starting time
        self._chrono.start = nil
        
        // Update in CoreData
        do {
            try self._context.save()
            print("Chrono stop saved")
        } catch {
            print("Can't saved: \(error)")
        }
        
        // Stop the timer
        self._timer.invalidate()
        
        // Update the button
        self._button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self._status = true
    }
}
