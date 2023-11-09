import UIKit

class ContainerViewController: UIViewController {
    
    // MARK: - Properties
    enum MenuState {
        case opened
        case closed
    }
    
    private var menuState: MenuState = .closed
    let menuViewController = MenuViewController()
    let taskListViewController = TaskListViewController()
    let archiveViewController = ArchiveViewController()
    let trashViewController = TrashViewController()
    var navigationViewController: UINavigationController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController()
        configureGestures()
        configureNavigationBar()
    }
    
    // MARK: - Setup methods
    private func addChildViewController() {
        menuViewController.delegate = self
        addChild(menuViewController)
        view.addSubview(menuViewController.view)
        menuViewController.didMove(toParent: self)
        
        taskListViewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: taskListViewController)
        addChild(navigationViewController)
        view.addSubview(navigationViewController.view)
        navigationViewController.didMove(toParent: self)
        self.navigationViewController = navigationViewController
    }
    
    // MARK: - Datasource update
        func updateCurrent() {
            taskListViewController.updateData()
        }
        
        func updateArchive() {
            archiveViewController.updateData()
        }
        
        func updateTrash() {
            trashViewController.updateData()
        }
    
    // MARK: - Menu interaction
    private func configureGestures() {
        view.addGestureRecognizer(swipeOpenMenu)
        view.addGestureRecognizer(swipeCloseMenu)
    }
    
    private func configureNavigationBar() {
        let barItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .done, target: self, action: #selector(didTapMenuButton))
        barItem.tintColor = .appText
        
        [taskListViewController, archiveViewController, trashViewController].forEach {
            $0.navigationItem.leftBarButtonItem = barItem
        }
        
        menuViewController.tasksNeedUpdate = {
            self.updateCurrent()
        }
    }
    
    private lazy var swipeOpenMenu: UISwipeGestureRecognizer = {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didTapMenuButton))
        gestureRecognizer.direction = .right
        return gestureRecognizer
    }()
    
    private lazy var swipeCloseMenu: UISwipeGestureRecognizer = {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeMenu))
        gestureRecognizer.direction = .left
        return gestureRecognizer
    }()
    
    private lazy var tapCloseMenu: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        return tapGesture
    }()
}

// MARK: - TaskListVC Delegate
extension ContainerViewController: TaskListViewControllerDelegate {
    @objc func didTapMenuButton() {
        toggleMenu(completion: nil)
    }
    
    @objc func closeMenu() {
        if menuState == .opened {
            toggleMenu(completion: nil)
        } else {
            return
        }
    }
    
    func toggleMenu(completion: (() -> Void)?) {
        switch menuState {
        case .closed:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navigationViewController?.view.frame.origin.x = self.taskListViewController.view.frame.size.width - 120
            } completion: { [weak self] done in
                if done {
                    self?.menuState = .opened
                }
            }
        case .opened:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navigationViewController?.view.frame.origin.x = 0
            } completion: { [weak self] done in
                if done {
                    self?.menuState = .closed
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
        }
    }
}

// MARK: - MenuVC Delegate
extension ContainerViewController: MenuViewControllerDelegate {
    func didSelect(menuItem: Int) {
        toggleMenu(completion: nil)
            switch menuItem {
            case 0:
                self.setViewController(to: self.taskListViewController)
            case 1:
                self.setViewController(to: self.archiveViewController)
            case 2:
                self.setViewController(to: self.trashViewController)
            default:
                return
            }
    }
    
    private func setViewController(to vc: UIViewController?) {
        guard let vc = vc else { return }
        navigationViewController?.setViewControllers([vc], animated: false)
    }
    
}
