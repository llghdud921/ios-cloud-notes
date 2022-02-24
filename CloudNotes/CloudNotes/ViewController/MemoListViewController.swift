import UIKit

final class MemoListViewController: UIViewController {
    private let tableView = UITableView()
    private var memos: [Memo] = []
    private let navigationTitle = "메모"
    private var selectedIndexPath: IndexPath?

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        configureNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
        setupMainListView()
    }

    private func setupMainListView() {
        configureTableView()
        configureListView()
        configureListViewAutoLayout()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelectionDuringEditing = true
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Assets.plusImage,
            style: .plain,
            target: self,
            action: #selector(createMemo)
        )
    }
    
    @objc private func createMemo() {
        let newMemoIndex = IndexPath(row: 0, section: 0)
        CoreDataManager.shared.create { error in
            presentErrorAlert(errorMessage: error.localizedDescription)
        }
        changeSelectedCell(indexPath: newMemoIndex)
        tableView.selectRow(at: newMemoIndex, animated: false, scrollPosition: .none)
    }
    
    private func changeSelectedCell(indexPath: IndexPath) {
        guard let splitViewController = splitViewController as? MainSplitViewController else { return }
        let selectedMemo = memos[indexPath.row]
        splitViewController.updateMemoContentsView(with: selectedMemo)
        self.selectedIndexPath = indexPath
    }
}

extension MemoListViewController: MemoReloadable {
    func reload() {
        memos = CoreDataManager.shared.load { error in
            presentErrorAlert(errorMessage: error.localizedDescription)
        }
        tableView.reloadData()
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
    }
}

// MARK: - TableViewDataSource
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

// MARK: - TableViewDelegate
extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeSelectedCell(indexPath: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, _  in
            self.presentDeleteAlert(currentMemo: self.memos[indexPath.row])
        }
        let shareAction = UIContextualAction(style: .normal, title: "공유") { _, sourceView, _ in
            self.presentActivityViewController(currentMemo: self.memos[indexPath.row], at: sourceView)
        }
        shareAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedIndexPath = nil
    }
    
    private func presentDeleteAlert(currentMemo: Memo) {
        let alert = UIAlertController(title: "진짜요?", message: "정말로 삭제하시겠어요?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            CoreDataManager.shared.delete(data: currentMemo) { error in
                self.presentErrorAlert(errorMessage: error.localizedDescription)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
    
    private func presentActivityViewController(currentMemo: Memo, at sourceView: UIView) {
        let memoDetail = currentMemo.entireContent
        let activityViewController = UIActivityViewController(
            activityItems: [memoDetail],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = sourceView
        present(activityViewController, animated: true)
    }
    
    private func presentErrorAlert(errorMessage: String) {
        let alert = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
