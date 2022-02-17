# 📝 동기화 메모장

1. 프로젝트 기간: 2022.02.07 - 2022.02.25
2. 팀원: 앨리 제인 조이
3. Ground Rules
    - 학습 시간
        - 시작시간 10시
        - 점심시간 1시~3시
        - 저녁시간 7시~9시
    - 스크럼
        - 10시에 스크럼 시작
4. 커밋 규칙
    1. 단위
        - 기능 단위
    - 메세지
        - 카르마 스타일
        

# 🗂 목차

```swift
# 목차

- [⌨️ 키워드](#-키워드)
- [STEP 1 : 리스트 및 메모영역 화면 UI구현](#STEP-1--리스트-및-메모영역-화면-UI구현)
    + [고민했던 것](#1-1-고민했던-것)
    + [Trouble Shooting](#1-2-Trouble-Shooting)
    + [배운 개념](#1-3-배운-개념)
- [STEP 2 : 코어데이터 DB 구현](#STEP-2--코어데이터-DB-구현)
    + [고민했던 것](#2-1-고민했던-것)
    + [Trouble Shooting](#2-2-Trouble-Shooting)
    + [배운 개념](#2-3-배운-개념)
    + [PR 후 개선사항](#2-4-PR-후-개선사항)

+ [📌 프로젝트 개요](#-프로젝트-설명)   
+ [📺 실행 화면](#-실행-화면)
+ [🧑‍💻 네트워크 모델 구성](#-네트워크-모델-구성)
+ [🎨 뷰 구성](#-뷰-구성)

[![top](https://img.shields.io/badge/top-%23000000.svg?&amp;style=for-the-badge&amp;logo=Acclaim&amp;logoColor=white&amp;)](#-동기화-메모장)
```

## Keyword

- `Core Data` `NSPersistentContainer`
    - `NSFetchRequest` `NSPredicate` `NSSortDescriptor`
    - `NSManagedObject` `NSManagedObjectContext`
- `UISplitViewController`
- `DateFormatter`
- `UITapGestureRecognizer`
- `Collection`  `subscript`
- `NavigationItem` `UIBarButtonItem`
- `UIActivityViewController` `UIAlertController`
    - `popoverPresentationController`
- `UITextView`
    - `UITextViewDelegate`
- `UITableView`
    - `UISwipeActionsConfiguration`
    - `selectRow` `deleteRows`
    - `UITableViewCell` `defaultContentConfiguration`
        - `NSMutableAttributedString`
        - `setSelected` `selectedBackgroundView`

# STEP 1 : 리스트 및 메모영역 화면 UI구현

리스트 화면과 메모영역 화면을 SplitViewController를 활용하여 구현합니다.

## 1-1 고민했던 것

### 양방향 델리게이트로 메모 목록과 상세페이지간 데이터 전달

메모 목록을 테이블뷰 형식으로 가지고있는 `MemoListViewController` 와, 메모의 내용을 표시하는 `memoDetailViewController` 간에 데이터 전달을 위하여 양방향으로 delegation 관계를 구현하였습니다.

`MemoListViewController`는 테이블뷰 셀이 선택되면 UITableViewDelegate 메서드 didSelectRowAt에서 `MemoDetailViewControllerDelegate` 프로토콜을 채택한 `memoDetailViewController` 에게 Memo 인스턴스를 전달하여 텍스트뷰에 표시할 데이터를 전달합니다.

`memoDetailViewController`는 사용자가 메모의 내용을 수정하면 `MemoListViewControllerDelegate`을 채택한 `MemoListViewController` 에게 변경된 텍스트뷰의 내용을 전달하여 수정사항을 메모 목록에 반영합니다.

### NSAttributedString과 defaultContentConfiguration을 이용한 테이블 뷰 셀 구성

<img src="https://i.imgur.com/JXo1jzg.png" width="50%" height="50%">

- subtitle에서 날짜와 메모 본문에 다른 attribute를 적용하기 위해 NSAttributedString을 사용했습니다
- 날짜는 footnote, 본문은 caption1 + secondaryLabel 색상으로 구성했습니다.

```swift
let attributedString = NSMutableAttributedString()

attributedString.append(NSAttributedString(
    string: dateString + " ",
    attributes: [.font: UIFont.preferredFont(forTextStyle: .footnote)]
))

attributedString.append(NSAttributedString(
    string: truncatedBody,
    attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor.secondaryLabel
    ]
))
```

### UISwipeActionsConfiguration 사용

TableView의 Cell을 swipe할 때 공유 및 삭제 기능을 위한 액션버튼이 띄워지도록 구현했습니다.

<img src="https://i.imgur.com/n5FNemO.png" width="50%" height="50%">

### 어플의 실행에 따른 selectRow(at:) 호출

- 앱이 처음 구동될 때 첫번째 셀이 선택되도록 했습니다.
- 메모를 추가했을 때 추가한 새로운 메모를 select 합니다.
- 메모를 삭제했을 때는 삭제한메모의 다음 메모를 자동으로 select 합니다.

어떤 메모를 선택해서 작성하고 있는지 알리기 위해 작성중인 셀이 계속 select 되도록 구현했습니다.

### 키보드의 text 가림현상 개선

`NotificationCenter`를 활용하여 키보드가 화면에 표시될 때, textView의 text를 가리지 않도록 contentInset을 키보드의 높이와 같게 조정하고, `textView.isEditable`을 사용하여 메모가 없을 때 textView를 수정할 수 없도록 구현했습니다.

<img src="https://user-images.githubusercontent.com/74536728/154416221-22c394ea-9025-4e51-b4e7-f19d7dae4cf5.gif" width="50%" height="50%">

### 안전하게 배열 조회

배열에서 존재하지않는 인덱스를 조회했을 때 Crash가 나지 않도록 subscript를 활용하여 안전하게 조회할 수 있도록 했습니다.

```swift
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
```

## 1-2 Trouble Shooting

### 1. GestureRecognizer의 cancelsTouchesInView 기본값 true

- GestureRecognizer를 ViewController에 추가하자 UITableView의 셀이 터치되지 않는 현상이 나타났습니다.
- `원인` 그 이유는 GestureRecognizer의 프로퍼티 cancelsTouchesInView의 기본값이 `true`이기 때문입니다. 제스처만 인식한 후 나머지 터치정보들을 뷰로 전달하지 않고 취소하기 때문에 UITableView의 UITableViewDelegate 메서드가 작동하지 않았습니다.
- `해결` 따라서 cancelsTouchesInView값을 `false`로 할당해줌으로써 제스처를 인식한 후에도 Gesture Recognizer와는 무관하게 터치 정보들을 뷰에 전달할 수 있게 되었습니다.

### 2. 셀 선택이 유지되지 않는 문제

|수정 전|수정 후|
|:---:|:---:|
|<img src="https://i.imgur.com/6nMVmAh.gif" width="50%" height="50%">|<img src="https://i.imgur.com/bhur7K6.gif" width="50%" height="50%">|

- `원인` tableView의 `allowsSelectionDuringEditing` 프로퍼티의 디폴트가 false였기 때문에 셀선택이 되지않았습니다.
- `해결`  `allowsSelectionDuringEditing` 를 true로 바꿔주었습니다. 셀을 지운 후에도 셀선택이 남아있도록 하기 위해 `didEndEditingRowAt`에서도 indexPath에 해당하는 row를 select하는 로직을 추가했습니다.
    
    ```swift
    // 셀을 지우는 동안 editing을 할 수 있도록 true로 변경
    tableView.allowsSelectionDuringEditing = true
    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
    
    // 셀 수정이 끝난 후에도 셀을 select하는 로직 추가
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
      guard let indexPath = indexPath else {
          return
      }
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
    }
    ```
    

### 3. 마지막 셀을 지웠을 때 index 오류가 나는 문제

```swift
Thread 1:
"Attempted to scroll the table view to an out-of-bounds row (0) when there are only 0 rows in section 0.
Table view: <UITableView: 0x13f031400;
frame = (0 0; 420 834);
clipsToBounds = YES;
autoresize = W+H; gestureRecognizers = <NSArray: 0x600000031680>;
layer = <CALayer: 0x600000ec7b80>; contentOffset: {0, -74};
contentSize: {420, 72.5}; adjustedContentInset: {74, 0, 20, 0};
dataSource: <CloudNotes.MemoListViewController: 0x14880fad0>>"
```

- `원인`  셀을 지운 후 다음 셀을 select해주는데, 맨 마지막 셀을 지우면 select할 row가 남아있지 않아서 index 오류가 발생했습니다.
- `해결`  조건문으로 지우려는 셀의 row가 남아있는 메모의 개수보다 작을때만 `tableView.selectRow(at: indexPath)` 를 하도록 분기해주었습니다. 추가로 맨 마지막 셀을 지우는 경우 detailViewController가 비어있는 텍스트뷰를 보여주도록 구현했습니다.

```swift
private func deleteMemo(at indexPath: IndexPath) {
    let deletedMemo = MemoDataManager.shared.memos[indexPath.row]
    MemoDataManager.shared.memos.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .none)
    MemoDataManager.shared.deleteMemo(id: deletedMemo.id)
    
    if indexPath.row < MemoDataManager.shared.memos.count {
        let memo = MemoDataManager.shared.memos[indexPath.row]
        delegate?.memoDetailViewController(showTextViewWith: memo)
        tableView.allowsSelectionDuringEditing = true
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
    } else {
		// 맨 마지막 셀을 지우는 경우
        delegate?.showEmptyTextView()
    }
}

func showEmptyTextView() {
    textView.isEditable = false
    textView.text = ""
}
```

## 1-3 배운 개념

- 코드로 뷰 구현하기: SceneDelegate 에서 initial View Controller 설정
    
    ### 코드로 뷰 구현하기: SceneDelegate 에서 initial View Controller 설정
    
    - 스토리보드를 지운 후 SceneDelegate의 scene메서드에서 window의 rootViewController를 앱의 첫화면에 보이는 splitViewController로 설정한합니다.
    - 그리고 `makeKeyAndVisible()`로 화면에 보이도록 설정하여 스토리보드에서 initial view controller로 지정하는 것을 대신해줄 수 있습니다.
    
    ```swift
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
            
        window = UIWindow(windowScene: windowScene)
        let splitViewController = SplitViewController(style: .doubleColumn)
        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
    }
    ```
    
- BarButtonItem 활용
    
    ### BarButtonItem 활용
    
    - UIViewController에 있는 `navigationItem` 프로퍼티를 사용하여 navigationbar에 필요한 item을 설정해줄 수 있다.
    - `UIBarButtonItem`의 생성자에는 barButtonSystemItem이나 image를 받아서 원하는 대로 설정해 사용할 수 있다.
    
    ```swift
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, 
    																		target: self, 
    																		action: #selector(addMemo))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.title = "메모"
    }
    
    private func setupNavigationItem() {
    		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
    																												style: .plain,
    																												target: self,
    																												action: #selector(viewMoreButtonTapped))
    }
    ```
    
- UISplitViewController
    
    ### UISplitViewController
    
    - `setViewController(_:for:)` : UISplitViewController의 메서드로 Double Column 스타일인 경우에 primary와 secondary 뷰컨트롤러를 지정합니다.
    - 이 메서드로 지정하는 경우에 자동으로 뷰컨트롤러에 네비게이션 컨트롤러를 감싸서
    UISplitViewController에 할당해주었습니다.
    - preferredDisplayMode = .oneBesideSecondary 로 앱 초기 화면에서 왼쪽에 메모 목록, 오른쪽엔 메모 상세화면이 같이 나오도록 설정하였습니다.
    
    ```swift
    class SplitViewController: UISplitViewController {
        private let listViewController = MemoListViewController()
        private let detailViewController = MemoDetailViewController()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupChildView()
            setupDisplay()
            listViewController.delegate = detailViewController
            detailViewController.delegate = listViewController
            hideKeyboard()
        }
        
        private func setupChildView() {
            setViewController(listViewController, for: .primary)
            setViewController(detailViewController, for: .secondary)
        }
        
        private func setupDisplay() {
            preferredSplitBehavior = .tile
            preferredDisplayMode = .oneBesideSecondary
        }
    }
    ```
    

# STEP 2 : 코어데이터 DB 구현

메모를 위한 코어데이터 모델을 생성합니다.

## 2-1 고민했던 것

### 코어데이터를 관리하는 매니저 타입 구현

- 데이터를 관리하는 타입인 `MemoDataManager` 를 구현했습니다.
    - fetch해온 데이터를 저장해 놓는 memos 배열을 가지고 있습니다.
    - CoreData를 생성, 삭제, 조회, 업데이트를 담당합니다.

### 사용자 친화적인 UI 구현

메모가 추가되거나 수정될 때 최신순으로 정렬하여 TableView에 보여줄 수 있도록 날짜를 기준으로 정렬했습니다.

메모리스트 뷰에서는 Swipe해서 share 버튼을 눌렀을 때, UIActivityView를 화면 중앙에 보여주도록 해주었고, 상세페이지의 barButtonItem에서 share 버튼을 눌렀을 때는, 해당 버튼에서부터 UIActivityView가 보여지도록 했습니다.

|Swipe해서 share 버튼을 눌렀을 때|barButtonItem에서 share 버튼을 눌렀을 때|
|:---:|:---:|
|<img src="https://i.imgur.com/Yn4FJqW.png" width="50%" height="50%">|<img src="https://i.imgur.com/28ZUpZF.png" width="50%" height="50%">|

### 아이패드에서 popoverPresentationController의 사용

- 오류메세지

아이폰에서는 잘 띄워지던 UIAlertController나 UIActivityViewController가 아이패드 환경에서는 작동하지 않았습니다. 

```
Thread 1: "Your application has presented a UIAlertController (<UIAlertController: 0x10d813a00>) of style UIAlertControllerStyleActionSheet from CloudNotes.SplitViewController (<CloudNotes.SplitViewController: 0x11f7068f0>).
The modalPresentationStyle of a UIAlertController with this style is UIModalPresentationPopover.
You must provide location information for this popover through the alert controller's popoverPresentationController.
You must provide either a sourceView and sourceRect or a barButtonItem.
If this information is not known when you present the alert controller, you may provide it in the UIPopoverPresentationControllerDelegate method -prepareForPopoverPresentation."

```

popoverPresentationController를 사용하여 얼럿이 띄워질 위치를 sender나 뷰의 특정한 위치로 명시를 하여 해결했습니다.

- sender를 준 경우

```swift
private func showAlert(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    // 코드 생략
    if let popoverController = alert.popoverPresentationController {
        popoverController.barButtonItem = sender
    }
    present(alert, animated: true, completion: nil)
}
```

- 좌표를 설정해준 경우

```swift
private func showActivityView(indexPath: IndexPath) {
    //코드 생략
    let activityViewController = UIActivityViewController(activityItems: [memoToShare], applicationActivities: nil)
    
    if let popOver = activityViewController.popoverPresentationController {
        popOver.sourceView = splitViewController.view
        popOver.sourceRect = CGRect(x: splitViewController.view.bounds.midX,
                                    y: splitViewController.view.bounds.midY,
                                    width: 0,
                                    height: 0)
        popOver.permittedArrowDirections = []
    }
    present(activityViewController, animated: true)
}
```

<img src="https://i.imgur.com/1Dv8067.png" width="50%" height="50%">

[관련 공식문서 링크: Displaying Transient Content in a Popover](https://developer.apple.com/documentation/uikit/windows_and_screens/displaying_transient_content_in_a_popover)

## 2-2 Trouble Shooting

### UITableView의 Cell을 deleteRows(at:) 메서드로 삭제했을 때 발생한 에러

```
Thread 1:
"Invalid update: invalid number of rows in section 0.
The number of rows contained in an existing section after the update (26) must be equal to the number of rows contained in that section before the update (26), plus or minus the number of rows inserted or deleted from that section (0 inserted, 1 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).
```

- `상황` tableView 섹션의 row 개수와 실제 보여줄 섹션의 개수가 맞지 않아서 발생하는 오류입니다.
- `이유` tableView의 셀을 삭제하면서 tableView에 보여줄 데이터도 같이 삭제 해주어야 하는데, 그 과정이 누락이되어 발생한 것으로 보입니다.
- `해결` 셀을 추가 및 삭제할 때 tableView에 보여줄 섹션의 개수도 동일하도록 `MemoDataManager`의 메모와 코어데이터에 저장된 메모데이터도 삭제 해주었습니다.

### 텍스트뷰가 변할때마다 메모가 저장되는 문제

|작성 중일때|앱을 다시 실행해서 코어데이터에서 fetch해왔을 때|
|:---:|:---:|
|<img src="https://i.imgur.com/yzjlrDt.png" width="50%" height="50%">|<img src="https://i.imgur.com/3ULs2Tt.png" width="50%" height="50%">|



- `상황` 텍스트뷰에 여러 글자를 적고, 앱을 다시 구동하면 오른쪽 사진처럼 한글자씩 메모가 여러개 생기는 오류입니다.
- `이유` 텍스트뷰가 수정이 될 때마다 코어데이터에 저장이 되기 때문에 발생한 문제였습니다.
    - DetailViewController에서 `currentMemo` 라는 연산프로퍼티로 현재 메모에 접근했는데,
    - 그 안에서 만들어주는 Memo 타입을 이니셜라이즈 할때 코어데이터의 context가 쓰이면서 글자를 수정한 수만큼 메모가 저장이 되고,
    - fetch를 해올 때 한 글자씩 저장 된 모든 메모들을 불러오면서 하나의 메모를 수정했지만, 수정한 글자 수대로 새로운 메모들이 생기는 현상이 발생하였습니다.

<수정 전>

```swift
extension MemoDetailViewController: UITextViewDelegate {
		private var currentMemo: Memo {
        let memoComponents = textView.text.split(
            separator: "\n",
            maxSplits: 1
        ).map(String.init)
        
        **let memo = Memo(context: MemoDataManager.shared.viewContext)**
        memo.title = memoComponents[safe: 0] ?? ""
        memo.body = memoComponents[safe: 1] ?? ""
        memo.lastModified = Date()
        
        return memo
    }

    func textViewDidChange(_ textView: UITextView) {
        delegate?.memoListViewController(updateTableViewCellWith: currentMemo)
    }
}

```

프린트문으로 출력해본 결과 `context`의 수는 글자가 입력할 때 마다 늘어나지만, `메모`의 수는 변함이 없는것을 확인할 수 있었습니다.

<img src="https://i.imgur.com/If3slj0.png" width="20%" height="20%">

```swift
extension MemoListViewController: MemoListViewControllerDelegate {
		func memoListViewController(updateTableViewCellWith memo: Memo) {
		    guard let indexPath = tableView.indexPathForSelectedRow else {
		        return
		    }
		    let request = NSFetchRequest(entityName: "Memo")
				//context의 수가 글자 입력할때마다 늘어남 
		    print(try? MemoDataManager.shared.viewContext.count(for: request))
				
		    MemoDataManager.shared.memos[indexPath.row] = memo
				//메모의 수는 그대로 
		    print(MemoDataManager.shared.memos.count)
		    tableView.reloadRows(at: [indexPath], with: .none)
		    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
		}
}
```

- `해결`  코어데이터의 `Memo(context:)` 객체를 이용하지 않고 그냥 메모 수정 화면에서 메모 목록으로 title, body를 자체를 전달하여 수정되고 있는 셀의 indexPath로 MemoDataManager에서 Memo 를 가져와서 MemoDataManager.shared.updateMemo 로 해당 Memo를 수정한 후 context를 save하는 방식으로 해결했습니다.

```swift
extension MemoDetailViewController: UITextViewDelegate {
		func textViewDidChange(_ textView: UITextView) {
        let memoComponents = textView.text.split(separator: "\n",
                                                 maxSplits: 1)
                                                .map(String.init)
        
        let title = memoComponents[safe: 0] ?? ""
        let body = memoComponents[safe: 1] ?? ""
        let lastModified = Date()
        
        delegate?.memoListViewController(updateTableViewCellWith: title, body: body, lastModified: lastModified)
    }
}

extension MemoListViewController: MemoListViewControllerDelegate {
		func memoListViewController(updateTableViewCellWith title: String, body: String, lastModified: Date) {
        guard let indexPath = tableView.indexPathForSelectedRow,
              let id = MemoDataManager.shared.memos[indexPath.row].id else {
            return
        }
        MemoDataManager.shared.updateMemo(id: id, title: title, body: body, lastModified: lastModified)
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
}

class MemoDataManager {
		func updateMemo(id: UUID,
                    title: String,
                    body: String,
                    lastModified: Date)
		    {
        let predicate = NSPredicate(format: "id == %@", id.uuidString)
        guard let memo = fetchMemos(predicate: predicate).first else {
            return
        }
        memo.title = title
        memo.body = body
        memo.lastModified = lastModified
        saveViewContext()
    }
}
```

### 마지막 Cell을 삭제했을 때, textView에 text가 남아있는 문제

MemoListViewController의 `deleteMemo()` 메소드 내부에서 조건문을 통해 마지막 Cell인지 확인 후 detailViewController에 있는 `showEmptyTextView()` 메소드를 호출해 textView의 text를 초기화 해주었습니다.

```swift
private func deleteMemo(at indexPath: IndexPath) {
    let deletedMemo = MemoDataManager.shared.memos[indexPath.row]
    MemoDataManager.shared.memos.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .none)
    MemoDataManager.shared.deleteMemo(id: deletedMemo.id)
        
    if indexPath.row < MemoDataManager.shared.memos.count {
        let memo = MemoDataManager.shared.memos[indexPath.row]
        delegate?.memoDetailViewController(showTextViewWith: memo)
        tableView.allowsSelectionDuringEditing = true
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
    } else {
        delegate?.showEmptyTextView()
    }
}
```

---

## 2-3 배운 개념

- UITableViewDelegate 메서드를 활용한 스와이프 기능
    
    ## [UITableViewDelegate 메서드를 활용한 스와이프 기능]
    
    tableView의 Delegate 메서드를 활용하여 셀을 스와이프 했을 때 선택할 수 있는 옵션을 선택할 수 있습니다. 
    
    - 왼쪽 → 오른쪽 스와이프
    - 오른쪽 → 왼쪽 스와이프
    
    ```swift
    func tableView(_ tableView: UITableView,
      leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
      ) -> UISwipeActionsConfiguration? {
          // ...
      }
    
    func tableView(_ tableView: UITableView,
          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
      ) -> UISwipeActionsConfiguration? {
          // ...
      }
    ```
