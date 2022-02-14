import UIKit

class MemoDetailViewController: UIViewController {
    private enum Constant {
        static let lineBreak: Character = "\n"
        static let navigationBarIconName = "ellipsis.circle"
        static let deleteWarningMessage = "정말 삭제하시겠습니까?"
        static let deleteAlertActionTitle = "OK"
        static let headerAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.preferredFont(for: .title1, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        static let bodyAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label
        ]
    }
    private var currentIndex: Int = .zero
    private let memoDetailTextView: UITextView = {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpNavigationItem()
        setUpTextView()
        setUpNotification()
        memoDetailTextView.delegate = self
    }
}

// MARK: - Update
extension MemoDetailViewController {
    func updateData(with index: Int) {
        currentIndex = index
        memoDetailTextView.text = MemoDataManager.shared.memoList[safe: currentIndex]?.body
        memoDetailTextView.attributedText = configureTextStyle()
    }
    
    func clearTextView() {
        memoDetailTextView.text = nil
    }
}

// MARK: - SetUp Navigation Item
extension MemoDetailViewController {
    private func setUpNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constant.navigationBarIconName),
            style: .plain,
            target: self,
            action: #selector(moreViewbuttonTapped(_:))
        )
    }
    @objc func moreViewbuttonTapped(_ sender: UIBarButtonItem) {
        guard let splitVC = self.splitViewController as? SplitViewController else {
            return
        }
        self.showMemoActionSheet(shareHandler: { _ in
            self.showActivityViewController(data: MemoDataManager.shared.memoList[self.currentIndex].body ?? "")
        }, deleteHandler: {_ in
            self.showAlert(
                message: Constant.deleteWarningMessage,
                actionTitle: Constant.deleteAlertActionTitle
            ) { _ in
                splitVC.deleteTableViewCell(
                    indexPath: IndexPath(row: self.currentIndex, section: .zero)
                )
            }
        }, barButtonItem: sender)
    }
}

// MARK: - SetUp UITextView
extension MemoDetailViewController {
    private func setUpTextView() {
        view.addSubview(memoDetailTextView)
        NSLayoutConstraint.activate([
            memoDetailTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            memoDetailTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            memoDetailTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            memoDetailTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setUpNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        var contentInset = memoDetailTextView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        memoDetailTextView.contentInset = contentInset
        memoDetailTextView.scrollIndicatorInsets = memoDetailTextView.contentInset
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        memoDetailTextView.contentInset = UIEdgeInsets.zero
        memoDetailTextView.scrollIndicatorInsets = memoDetailTextView.contentInset
    }
}

// MARK: - UITextView Font Setting
extension MemoDetailViewController {
    private func configureTextStyle() -> NSMutableAttributedString? {
        guard let memo = MemoDataManager.shared.memoList[safe: currentIndex]?.body?.split(
            separator: Constant.lineBreak,
            maxSplits: 1
        ) else {
            return nil
        }
        let titleText = memo[safe: 0]?.description
        let bodyText = memo[safe: 1]?.description
        
        let attributedString = NSMutableAttributedString()
        let title = attributedText(
            (titleText ?? "") + Constant.lineBreak.description,
            font: .preferredFont(for: .title1, weight: .bold),
            color: .label
        )
        let body = attributedText(
            bodyText ?? "",
            font: .preferredFont(forTextStyle: .body),
            color: .label
        )
        attributedString.append(title)
        attributedString.append(body)
        return attributedString
    }
    
    private func attributedText(_ text: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
        let string = text as NSString
        let attributedText = NSMutableAttributedString(string: text)
        let range: NSRange = string.range(of: text)
        attributedText.addAttribute(.font, value: font, range: range)
        attributedText.addAttribute(.foregroundColor, value: color, range: range)
        return attributedText
    }
}

// MARK: - TextViewDelegate
extension MemoDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let titleRange = currentText.range(of: Constant.lineBreak.description)
        if titleRange.location < range.location {
            textView.typingAttributes = Constant.bodyAttributes
        } else {
            textView.typingAttributes = Constant.headerAttributes
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let splitVC = self.splitViewController as? SplitViewController else {
            return
        }
        updateMemoData(with: textView.text)
        splitVC.updateMemoList(at: currentIndex)
        guard currentIndex != .zero else {
            return
        }
        MemoDataManager.shared.moveMemoList(from: currentIndex, to: .zero)
        splitVC.moveTableViewCell(at: currentIndex)
        currentIndex = .zero
    }
    
    private func updateMemoData(with text: String) {
        let data = text.split(separator: Constant.lineBreak, maxSplits: 1)
        let lastModified = Date().timeIntervalSince1970
        let title = data[safe: .zero]?.description
        let body = text
        guard let id = MemoDataManager.shared.memoList[safe: currentIndex]?.id else {
            return
        }
        MemoDataManager.shared.updateMemo(id: id, title: title, body: body, lastModified: lastModified)
    }
}
