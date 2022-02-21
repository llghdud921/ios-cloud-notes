import UIKit

private let reuseIdentifier = "Cell"

final class MemoListViewController: UITableViewController {
  weak var delegate: MemoDisplayable?
  private var memos = CoreDataMemos.shared
  private let firstRowIndexPath = IndexPath(row: 0, section: 0)
  private var currentMemoIndexPath = IndexPath(row: 0, section: 0)
  private var keyboardShowNotification: NSObjectProtocol?
  private var keyboardHideNotification: NSObjectProtocol?

  deinit {
    removeObservers()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setNavigationBar()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    tableView.allowsSelectionDuringEditing = true
    do {
      try memos.reload()
    } catch {
      showAlert(title: "Load fail")
    }
    if memos.isEmpty == false {
      loadDetail(at: firstRowIndexPath)
    } else {
      delegate?.set(editable: false, needClear: true)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if memos.isEmpty == false {
      tableView.selectRow(at: currentMemoIndexPath, animated: false, scrollPosition: .top)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    addObservers()
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    tableView.selectRow(at: currentMemoIndexPath, animated: false, scrollPosition: .none)
  }

  private func addObservers() {
    if keyboardShowNotification == nil {
      let bottomInset = view.safeAreaInsets.bottom
      let addSafeAreaInset: (Notification) -> Void = { [weak self] notification in
        guard
          let self = self,
          let userInfo = notification.userInfo,
          let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
          return
        }
        self.additionalSafeAreaInsets.bottom = keyboardFrame.height - bottomInset
      }
      
      keyboardShowNotification = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardWillShowNotification,
        object: nil,
        queue: nil,
        using: addSafeAreaInset
      )
    }
    if keyboardHideNotification == nil {
      let removeSafeAreaInset: (Notification) -> Void = { [weak self] _ in
        self?.additionalSafeAreaInsets.bottom = 0
      }
      
      keyboardHideNotification = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardWillHideNotification,
        object: nil,
        queue: nil,
        using: removeSafeAreaInset
      )
    }
  }

  private func removeObservers() {
    if let keyboardShowNotification = keyboardShowNotification {
      NotificationCenter.default.removeObserver(keyboardShowNotification)
      self.keyboardShowNotification = nil
    }
    if let keyboardHideNotification = keyboardHideNotification {
      NotificationCenter.default.removeObserver(keyboardHideNotification)
      self.keyboardHideNotification = nil
    }
  }

  private func setNavigationBar() {
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMemo))
    navigationItem.rightBarButtonItem = addButton
    navigationItem.title = "메모"
  }

  @objc private func addMemo() {
    do {
      try memos.createFirst(title: "", body: "")
      tableView.insertRows(at: [firstRowIndexPath], with: .fade)
      tableView.selectRow(at: firstRowIndexPath, animated: true, scrollPosition: .top)
      loadDetail(at: firstRowIndexPath)
    } catch {
      showAlert(title: "Save fail")
    }
  }
  
  private func removeMemo(at indexPath: IndexPath) {
    do {
      try self.memos.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      if self.memos.isEmpty == false {
        self.currentMemoIndexPath.row -= self.currentMemoIndexPath.row > indexPath.row ?  1 : 0
      } else {
        delegate?.set(editable: false, needClear: true)
      }
    } catch {
      self.showAlert(title: "Remove fail")
    }
  }

  private func loadDetail(at indexPath: IndexPath) {
    let memo = memos[indexPath.row]
    currentMemoIndexPath = indexPath
    delegate?.showMemo(title: memo.title, body: memo.body)
    delegate?.set(editable: true, needClear: false)
  }
}

// MARK: - MemoStorable

extension MemoListViewController: MemoStorable {
  func updateMemo(title: String, body: String) {
    let index = currentMemoIndexPath.row
    do {
      try memos.update(at: index, title: title, body: body)
      tableView.reloadData()
      tableView.selectRow(at: currentMemoIndexPath, animated: false, scrollPosition: .none)
    } catch {
      showAlert(title: "Update fail")
    }
  }
}

// MARK: - MemoActivityDelegate

extension MemoListViewController: MemoActivityDelegate {
  func removeCurrentMemo() {
    if memos.isEmpty == false {
      removeMemo(at: currentMemoIndexPath)
    }
  }
}

// MARK: - UITableViewDataSource

extension MemoListViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return memos.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    let memo = memos[indexPath.row]
    var configuration = cell.defaultContentConfiguration()
    let title = memo.title ?? ""
    configuration.text = title.isEmpty ? "새로운 메모" : title
    configuration.secondaryAttributedText = memo.subtitle
    configuration.textProperties.numberOfLines = 1
    configuration.secondaryTextProperties.numberOfLines = 1
    cell.contentConfiguration = configuration
    cell.accessoryType = .disclosureIndicator
    return cell
  }
}

// MARK: - UITableViewDelegate

extension MemoListViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    loadDetail(at: indexPath)
    splitViewController?.show(.secondary)
  }
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, completionHandler in
      self.removeMemo(at: indexPath)
      completionHandler(true)
    }
    deleteAction.image = UIImage(systemName: "trash")
    let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
    return configuration
  }
  
  override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
    guard tableView.numberOfRows(inSection: 0) != 0 else { return }
    let section = currentMemoIndexPath.section
    let numberOfRows = tableView.numberOfRows(inSection: section)
    let maximumVaildRow = numberOfRows - 1
    let willSelectIndexPath: IndexPath

    if maximumVaildRow < currentMemoIndexPath.row {
      willSelectIndexPath = IndexPath(row: maximumVaildRow, section: section)
    } else if numberOfRows > 1 {
      willSelectIndexPath = currentMemoIndexPath
    } else {
      willSelectIndexPath = firstRowIndexPath
    }
    tableView.selectRow(at: willSelectIndexPath, animated: false, scrollPosition: .none)
    self.loadDetail(at: willSelectIndexPath)
  }
}
