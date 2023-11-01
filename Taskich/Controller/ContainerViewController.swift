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
    
    // MARK: - Datasource methods
    func addTaskToArchive(task: Task) {
        archiveViewController.addTask(task: task)
    }
    
    func addTaskToTrash(task: Task) {
        trashViewController.addTask(task: task)
    }
    
    func unarchivedTask(task: Task) {
        taskListViewController.appendTask(task: task)
    }
    
    func returnDeletedTask(task: Task) {
        taskListViewController.appendTask(task: task)
    }
}

// MARK: - TaskListVC Delegate
extension ContainerViewController: TaskListViewControllerDelegate {
    @objc func didTapMenuButton() {
        toggleMenu(completion: nil)
    }
    
    func toggleMenu(completion: (() -> Void)?) {
        switch menuState {
        case .closed:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navigationViewController?.view.frame.origin.x = self.taskListViewController.view.frame.size.width - 220
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
    func didSelect(menuItem: MenuViewController.MenuOptions) {
        toggleMenu(completion: nil)
            switch menuItem {
            case .tasks:
                self.setViewController(to: self.taskListViewController)
            case .archive:
                self.setViewController(to: self.archiveViewController)
            case .trash:
                self.setViewController(to: self.trashViewController)
            }
        
    }
    
    private func setViewController(to vc: UIViewController?) {
        guard let vc = vc else { return }
        navigationViewController?.setViewControllers([vc], animated: false)
        let barItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .done, target: self, action: #selector(didTapMenuButton))
        barItem.tintColor = .black
        
        vc.navigationItem.leftBarButtonItem = barItem
    }
}
