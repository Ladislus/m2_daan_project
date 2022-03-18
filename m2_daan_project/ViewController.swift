import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var _tableview: UITableView!
    var _context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self._tableview.dataSource = self
    }
    
    @IBAction func addCategory() {
        let newCategory = Category(context: self._context)
        newCategory.name = "Default"
        
        let newTimer = Timer(context: self._context)
        newTimer.name = "Timer 1"
        newTimer.start = nil
        newTimer.end = nil
        newTimer.time = 0.0
        newTimer.category = newCategory

        do {
            try self._context.save()
            print("Saved category: '" + newCategory.name! + "'")
            self._tableview.reloadData()
        } catch {
            print("Can't save: \(error)")
        }
    }
    
    @IBAction func playButtonClick(_ sender: UIButton) {
        let data: String = sender.restorationIdentifier!
        let section: Int = Int(data.split(separator: ";")[0]) ?? -1
        let row: Int = Int(data.split(separator: ";")[1]) ?? -1
        if (row < 0 || section < 0) {
            exitWithMsg(Message: "Row or section invalid")
        }
        //TODO: Delete task & reload table
    }
    
    private func exitWithMsg(Message msg: String?) {
        if let msg = msg {
            print("[Error] " + msg)
        }
        exit(1)
    }
    
    private func getAllCategories() -> [Category] {
        let rqst = Category.fetchRequest()
        do {
            return try self._context.fetch(rqst)
        } catch {
            print(error)
            self.exitWithMsg(Message: "Couldn't fetch all categories")
            // Unreachable
            return []
        }
    }
    
    // Fonction qui précise le nombre de sections à afficher
    func numberOfSections(in tableView: UITableView) -> Int {
        do {
            let count: Int = try self._context.count(for: Category.fetchRequest())
            return count
        } catch {
            print(error)
            self.exitWithMsg(Message: "Couldn't fetch category count")
            // Unreachable
            return -1
        }
    }
        
    // Fonction qui retourne le nombre d'éléments à afficher par section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cats = self.getAllCategories()
        let maxIndex: Int = cats.count - 1
        if (section > maxIndex) { exitWithMsg(Message: "Section index: \(section) is out of bounds [0; \(maxIndex)] in method 'tableView(numberOfRowsInSection)'") }
        if let timers = cats[section].timers {
            return timers.count
        } else {
            return 0 
        }
    }

    // Fonction appelée pour gérer les headers (une section = une catégorie de tâches) de la TableView
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let cats = self.getAllCategories()
        let maxIndex: Int = cats.count - 1
        if (section > maxIndex) { exitWithMsg(Message: "Section index: \(section) is out of bounds [0; \(maxIndex)] in method 'tableView(titleForHeaderInSection)'") }
        return cats[section].name
    }

    // Fonction appelée pour créer une case et la remplir
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let timer = self.getAllCategories()[indexPath.section].timers?.object(at: indexPath.row) as! Timer
        cell._text?.text = timer.name
        cell._label.text = "\(String(format: "%.2f", timer.time))s"
        cell._play.restorationIdentifier = "\(indexPath.section);\(indexPath.row)"
        return cell
    }
}
