import UIKit

class CategoryCell: UITableViewCell {
    @IBOutlet weak var _title: UILabel!
    @IBOutlet weak var _time: UILabel!
    
    var _category: Category!
    var _timer: Timer!
    
    func start() {
        self._timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc private func update() {
//        print("Update category '\(self._category.name ?? "")'")
        
        let t = totalTime(self._category)
        self._time.text = secondsToString(TimeInSeconds: t)
    }
}
