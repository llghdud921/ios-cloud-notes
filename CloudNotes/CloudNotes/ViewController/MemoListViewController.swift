import UIKit

final class MemoListViewController: UIViewController {
    private let tableView = UITableView()
    private var memos: [Memo] = []
    private let navigationTitle = "메모"

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        configureNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMemos()
        setupMainListView()
    }
    
    private func loadMemos() {
        guard let data = Assets.sampleData,
              let decodedData = try? JSONDecoder().decode([Memo].self, from: data.data) else { return }
        memos = decodedData
    }
    
    private func setupMainListView() {
        configureTableView()
        configureListView()
        configureListViewAutoLayout()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MemoListTableViewCell.self)
    }

    private func configureListView() {
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureListViewAutoLayout() {
        view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
    }
    
    private func configureNavigationBar() {
        navigationItem.title = navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem?.image = Assets.plusImage
    }
}

extension MemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(MemoListTableViewCell.self, for: indexPath) else {
            return UITableViewCell()
        }
        cell.setupLabel(from: memos[indexPath.row])

        return cell
    }
}

extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let splitViewController = splitViewController as? MainSplitViewController else { return }
        let selectedMemo = memos[indexPath.row]
        splitViewController.updateMemoContentsView(with: selectedMemo)
    }
}
