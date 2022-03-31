import Foundation

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var _tableview: UITableView!
    let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UITable settings
        self._tableview.dataSource = self
        self._tableview.delegate = self
    }
    
    // Fetch all categories from CoreData
    private func getAllEvent() -> [ApplicationEvent] {
        let rqst = ApplicationEvent.fetchRequest()
        do {
            return try self._context.fetch(rqst)
        } catch {
            print(error)
            exitWithMsg(Message: "Couldn't fetch all events")
            // Unreachable
            return []
        }
    }
    
    // Function returning the number of row in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            let count: Int = try self._context.count(for: ApplicationEvent.fetchRequest())
            return count
        } catch {
            print(error)
            exitWithMsg(Message: "Couldn't fetch event count")
            // Unreachable
            return -1
        }
    }
    
    // Function which create a new cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.getAllEvent()[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCellIdentifier", for: indexPath) as! EventCell
        cell._text.text = "[\(formatter.string(from: event.time!))] \(event.event!)"
        
        return cell
    }
}
