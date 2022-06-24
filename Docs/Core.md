# Core

This subframework contains essential elements and classes that allows you to start building your application.

## ViewController lifecycle

Each ios application has own architecture pattern. Core framework of STT suggest as basis MVP with benefits of basic classes which contains specific logic that usually go across view controllers in the application.

### MVP support

View layer contains several protocols and basic classes thar provide your application with powerful patternable code for MVP

`Viewable` - basic protocol that all views in your app should conform.
`ViewControllerType` - basic protocol for all view controllers in the app that brins support for MVP and Presenter.
`SttViewController<Presenter>` - basic class which is a replacement for UIViewController, as a generic parameter type of presenter is used.
`SttKeyboardViewController<Presenter>` - basic class which is a replacement for UIViewController that should be used if you want to have powerful support of adaptable UI with input fields. In this case, UI has to put all elements inside `UIScrollView` and this class will automatically resize your contents.
`Presenter<View>` - basic class for all presenters in the application where generic type is a ViewDelegate.

Example of codebase
```
// VIEW

protocol LoginViewControllerDelegate: Viewable { 
    // functions goes here
}

final class LoginViewController: SttViewController<LoginViewPresenter>, LoginViewControllerDelegate {
    // vc setups goes here
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // presenter can be accessed via presenter properties (you must set it in your coordinator or assemble when you create your ViewController)
    }
    
    override func style() {
        super.style()
        // configure your ui elements here
    }
}

final class LoginViewPresenter: Presenter<LoginViewControllerDelegate> {

    // common init for presenter
    init(viewable: LoginViewControllerDelegate) {
        // in this init you must pass instance of your view controller
        super.init()
        super.injectView(delegate: view)
    }
}

// common implementation pattern of assembler

func instantiateLoginView() -> LoginViewController {
    let viewController = LoginViewController()
    viewController.presenter = LoginPresenter(viewable: viewController)
    return viewController
}

```

## Command

This is the implementation of the Command pattern for basic sync and async requests that brings managing support as Operation does but in a simpler way. Along with Extension and RxExtension it allows a binding command to the UIElement to show the loading process. Each command that exists in library `Command` & `CommandWithParameter` conforms to the `CommandType`. In case when you need your own implementation and want to keep the existing powerful extension method, implement it in your class.

Common patter of command creation in the Presenter.
```
private(set) lazy var login = Command(
    delegate: self,
    handler: onLogin: { $0.onLogin() }, 
    handlerCanExecute: { $0.canExecuteLogin }
    )
    
    var canExecuteLogin: Bool { true }
    
    func onLogin() {
        // login perform here
        // along with RxExtension you may make your command auto async without it you must manage it by yourslef
        repository.login(credentials: credentials)
            .useWork(login)
    }
}

// on the view side or other you can easily call to your piece of work
if presenter.login.canExecute() {
    presenter.login.execute()
}
```

In some cases it might be useful to pass parameter to the command as initial state. In this case you must create `CommandWithParameter`.
```
private(set) lazy var login = CommandWithParameter(
    delegate: self,
    handler: onLogin: { $0.onLogin($1) }, 
    handlerCanExecute: { $0.canExecuteLogin($1) }
    )
    
    func canExecuteLogin(_ state: Bool) -> Bool { 
        // calculate if command can be executed
    }
    
    func onLogin(_ state: Bool) {
        // login perform here
        // along with RxExtension you may make your command auto async without it you must manage it by yourslef
        repository.login(credentials: credentials, state: state)
            .useWork(login)
    }
}

// on the view side or other you can easily call to your piece of work
if presenter.login.canExecute(parameter: self.state) {
    presenter.login.execute(parameter: self.state)
}
```

## Collections

The most important and useful part of this sub part of STT library. These classes bring support for the auto updatable collection including all possible ones `UITableView`, `UICollectionView` for single one and with sections. This classes require MVP architecture for both: parent and items.

Let's imagine that we need to show to user list of his books. In this case we need to create presenters for both page `BookListViewController` (see the ViewController lifecycle section for more information) and `BookListTVCellPresenter`. All procedure and steps will be same as for ViewController including all needed files (Presenter, ViewDelegate). As `UIViewController` is replaced by `SttViewController<Presenter>`, an `UITableView` is replaced by `SttTableView<Presenter>` and an `UICollectionViewCell` is replaced by `SttCollectionViewCell<Presenter>`.

Below is provided typical codebase for the single table view without sections.

```
// ViewCell

protocol BookTVCellViewDelegate: Viewable {
    // function goes here
}

final class BookTVCell: Presenter<BookTVCellPresenter>, BookTVCellViewDelegate {
    // declare reusable identifier for this cell
    static let reusableIdentifier = "BookTVCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // you can prepare you cell for reuse and clear binding set if you use Binding module of STT
    }
    
    override func prepareBind() {
        super.prepareBind()
        
        // set all properties here
    }
}

final class BookTVCellPresenter: Presenter<BookTVCellViewDelegate> {

    // declare parent property to the container in case when we need to report something to parent
    unowned private(set) var parent: BookTVCellDelegate

    init(parent: BookTVCellDelegate) {
        self.parent = parent
    }
}

// This delegate may be skiped when you do not need parent insdie your table view items 
protocol BookTVCellViewDelegate: AnyObject {
    // method of parent goes here
}

// View Controller

protocol BookListViewDelegate: Viewable {
    func pageSetuped()
}

final class BookListViewController: SttViewController<BookListPresenter>, BookListViewDelegate {
    
    let tableView = UITableView() 
    
    // declaration of auto updatable table view source
    
    private var booksSource: BooksTVSource!
    
    // tableView setup goes inside viewDidLoad
    
    override func bind() {
        super.bind()
        booksSource = BooksTVSource(
            tableView: tableView, 
            collection: presenter.books,
            // you may also pass here parameters if neeeded
            selectItem: presenter.selectItem
            )
    }
}

// Presenter of BookList page

final class BookListViewPresenter: Presenter<BookListViewDelegate> {

    // common init (see viewcontroller lifecycle section)
    
    let books = ObservableCollection<BookTVCellPresenter>()
    
    func loadBooks() {
        // ObservableCollection conforms to Collection protocol and contains other usefull method when you have async updates
        // lets imagine that we receive books
        repository.loadBooks { books in
            self.books.append(contentsOf: books)
            // Congratulations, no more code needed. Your page will automatically show books that you've just added
        }
    }
}

// TableViewSource

final class BooksTVSource: TableViewSource<BookTVCellPresenter> {

    private weak var selectItem: CommandWithParameter<BookTVCellPresenter>!
    
    convenience init(
        tableView: UITableView,
        collection: ObservableCollection<BookTVCellPresenter>,
        click: CommandWithParameter<BookTVCellPresenter>
        ) {
        
        self.init(
            tableView: tableView,
            cellIdentifiers: [
                CellIdentifier(identifers: BookTVCell.reusableIdentifier)
            ],
            collection: collection
        )
        
        self.click = click
    }
    
    // you can override UITableViewDelegate and UITableViewSource method here
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with presenter: BookTVCellPresenter) {
        selectItem.execute(parametr: presenter)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
```

In some cases we need to have async update of collection. If that happens we need to put all our code inside `performBatchUpdates` or use `beginUpdates` along with `endUpdates`. You should use this function when you have modifiction of source in one place, like insert then remove or reorder. If you will call this methods sequence without `performBatchUpdates` the UI might be broken and cell may be in unsycned state.

```
func loadBooks() {
    repository.loadBooks { books in
        // when this function is being called no other sources can push notification to the UI. It stops updating UI until returns from performBatchUpdates function.
        self.books.performBatchUpdates {
            // let's imagine that we must insert special books on the first place
            books.append(specialBook)
            // and then append books that we receive from the source
            books.append(contentsOf: books)
        }
    }
}
```

The same logic and steps you follow when you need CollectionView. In case when you need sections you must `source` inherit from `TableViewSourceWithSection` or `CollectionViewSourceWithSection`. Also your ObservableCollection must have special structure `SectionData<CellPresenter, SectionPresenter>`.

## Event and Global Observer

To be done...
