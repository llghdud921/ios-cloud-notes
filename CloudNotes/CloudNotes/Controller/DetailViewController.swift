import UIKit

final class DetailViewController: UIViewController {
  weak var delegate: MemoStorable?
  private let textView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.preferredFont(forTextStyle: .body)
    textView.keyboardDismissMode = .interactive
    return textView
  }()
  private var keyboardShowNotification: NSObjectProtocol?
  private var keyboardHideNotification: NSObjectProtocol?

  private var currentMemo: Memo {
    let memoComponents = textView.text.split(
      separator: "\n",
      maxSplits: 1,
      omittingEmptySubsequences: false
    ).map(String.init)
    let title = memoComponents[safe: 0] ?? ""
    let body = memoComponents[safe: 1] ?? ""
    let date = Date()
    return Memo(title: title, body: body, lastModified: date)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(textView)
    textView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textView.topAnchor.constraint(equalTo: view.topAnchor),
      textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    textView.delegate = self
    
    setNavigationBar()
  }

  override func viewDidAppear(_ animated: Bool) {
    addObservers()
  }

  override func viewDidDisappear(_ animated: Bool) {
    removeObservers()
  }

  private func addObservers() {
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

    let removeSafeAreaInset: (Notification) -> Void = { [weak self] _ in
      self?.additionalSafeAreaInsets.bottom = 0
    }

    keyboardShowNotification = NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillShowNotification,
      object: nil,
      queue: nil,
      using: addSafeAreaInset
    )
    keyboardHideNotification = NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil,
      queue: nil,
      using: removeSafeAreaInset
    )
  }

  private func removeObservers() {
    guard
      let keyboardShowNotification = keyboardShowNotification,
      let keyboardHideNotification = keyboardHideNotification else { return }
    NotificationCenter.default.removeObserver(keyboardShowNotification)
    NotificationCenter.default.removeObserver(keyboardHideNotification)
  }
  
  private func setNavigationBar() {
    let buttonImage = UIImage(systemName: "ellipsis.circle")
    let ellipsisCircleButton = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: nil)
    navigationItem.rightBarButtonItem = ellipsisCircleButton
  }
}

// MARK: - MemoDisplayable

extension DetailViewController: MemoDisplayable {
  func show(memo: Memo?) {
    let title = memo?.title ?? ""
    let body = memo?.body ?? ""
    textView.text = title.isEmpty && body.isEmpty ? "" : title + "\n" + body
    textView.endEditing(true)
    let topOffset = CGPoint(x: 0, y: 0 - view.safeAreaInsets.top)
    textView.setContentOffset(topOffset, animated: false)
  }
}

// MARK: - UITextViewDelegate

extension DetailViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    delegate?.update(currentMemo)
  }
}
