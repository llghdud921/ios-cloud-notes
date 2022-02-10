import UIKit

class SplitViewController: UISplitViewController {
    enum Constans {
        static let maximumTitleLength = 40
        static let maximumBodyLength = 70
    }
    
    private var memoList = [Memo]()
    private let primaryVC = MemoListViewController(style: .insetGrouped)
    private let secondaryVC = MemoDetailViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpChildView()
        setUpDisplay()
        setUpData()
        present(at: 0)
        hideKeyboard()
    }
    
    func updateMemoList(at index: Int, with data: Memo) {
        memoList[index] = data
        let title = data.title?.prefix(Constans.maximumTitleLength).description ?? "새로운 메모"
        let body = data.body?.prefix(Constans.maximumBodyLength).description ?? "추가 텍스트 없음"
        let lastModified = data.lastModified.formattedDate
        let memoListInfo = MemoListInfo(title: title, body: body, lastModified: lastModified)
        primaryVC.updateData(at: index, with: memoListInfo)
    }
    
    func present(at indexPath: Int) {
        let title = memoList[safe: indexPath]?.title ?? ""
        let body = memoList[safe: indexPath]?.body ?? ""
        secondaryVC.updateTextView(with: MemoDetailInfo(title: title, body: body))
        secondaryVC.updateIndex(with: indexPath)
        show(.secondary)
    }
}

// MARK: - 초기 ViewController 설정
extension SplitViewController {
    private func setUpChildView() {
        setViewController(primaryVC, for: .primary)
        setViewController(secondaryVC, for: .secondary)
    }
    
    private func setUpDisplay() {
        delegate = self
        preferredSplitBehavior = .tile
        preferredDisplayMode = .oneBesideSecondary
    }
    
    private func setUpData() {
        guard let fetchedData = MemoDataManager.shared.fetch() else {
            return
        }
        memoList = fetchedData
        
    }
    
    private func setUpDataForMemoList() {
        var memoListInfo = [MemoListInfo]()
        memoList.forEach { memo in
            let title = memo.title?.prefix(Constans.maximumTitleLength).description ?? "새로운 메모"
            let body = memo.body?.prefix(Constans.maximumBodyLength).description ?? "추가 텍스트 없음"
            let lastModified = memo.lastModified.formattedDate
            memoListInfo.append(MemoListInfo(title: title, body: body, lastModified: lastModified))
        }
        primaryVC.setUpData(data: memoListInfo)
    }
}

// MARK: - Delegate
extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        return .primary
    }
}
