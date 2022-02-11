import UIKit

protocol MemoSelectionDelegate: AnyObject {
    var memoSelectionDestination: UIViewController { get }
    func applyData(with description: String)
}

final class MasterTableViewController: UITableViewController {
    // MARK: - Properties
    var memoDataSource: MasterTableViewDataSourceProtocol?
    weak var delegate: MemoSelectionDelegate?
    
    // MARK: - Initializer
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    convenience init(style: UITableView.Style, dataSource: MasterTableViewDataSourceProtocol = MasterTableViewDataSource(), delegate: MemoSelectionDelegate) {
        self.init(style: style)
        self.memoDataSource = dataSource
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        navigationItem.title = "메모"
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: nil)
    }
    
    private func configureTableView() {
        tableView.dataSource = memoDataSource as? UITableViewDataSource
        tableView.register(MasterTableViewCell.self, forCellReuseIdentifier: MasterTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let memos = memoDataSource?.memos else {
            return
        }
        
        guard let destination = delegate?.memoSelectionDestination as? DetailViewController else {
            return
        }
        
        destination.applyData(with: memos[indexPath.row].description)
        splitViewController?.showDetailViewController(UINavigationController(rootViewController: destination), sender: self)
    }
}
