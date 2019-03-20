//
//  RxPageViewController.swift
//  RxPageViewController
//
//  Created by 王小涛 on 2019/3/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt

public class RxPageViewController: UIViewController {

    private var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 0.0])

    private let disposeBag = DisposeBag()

    private var controllers: [UIViewController] = [] {
        didSet {
            _totalPages.accept(controllers.count)
        }
    }

    private let _currentIndex = BehaviorRelay<Int>(value: 0)

    public var currentIndex: Observable<Int> {
        return _currentIndex.distinctUntilChanged()
    }

    public func scrollToIndex(index: Int, animated: Bool = true) {

        guard index >= 0 && index < controllers.count else {
            return
        }

        guard index != _currentIndex.value else {
            return
        }

        let direction: UIPageViewController.NavigationDirection = {
            if index < _currentIndex.value  {
                return .reverse
            } else {
                return .forward
            }
        }()

        let controller = controllers[index]
        pageViewController.setViewControllers([controller], direction: direction, animated: animated)

        _currentIndex.accept(index)
    }

    public func scrollToNext(animated: Bool = true) {
        let index = _currentIndex.value + 1
        scrollToIndex(index: index, animated: animated)
    }

    public func scrollToPrevious(animated: Bool = true) {
        let index = _currentIndex.value - 1
        scrollToIndex(index: index, animated: animated)
    }

    private let _totalPages = BehaviorRelay<Int>(value: 0)

    public var totalPages: Observable<Int> {
        return _totalPages.distinctUntilChanged()
    }

    public func reset() {
        controllers = []
        _currentIndex.accept(0)
        reloadData(animated: false)
    }

    public func addController(_ controller: UIViewController) {
        controllers.append(controller)
        reloadData(animated: false)
    }

    public func insertController(_ controller: UIViewController, at index: Int) {
        guard index >= 0 && index <= controllers.count else {
            return
        }
        controllers.insert(controller, at: index)
        if index <= _currentIndex.value {
            _currentIndex.accept(_currentIndex.value + 1)
        }
        reloadData(animated: false)
    }

    public func removeController(at index: Int, animated: Bool = true) {
        guard index >= 0 && index < controllers.count else {
            return
        }

        var direction: UIPageViewController.NavigationDirection = .forward
        var animated: Bool = false
        if index < _currentIndex.value {
            _currentIndex.accept(_currentIndex.value - 1)
        } else if index == _currentIndex.value {
            if index == controllers.count - 1 {
                direction = .reverse
                _currentIndex.accept(_currentIndex.value - 1)
            }
            animated = true
        }
        controllers.remove(at: index)
        reloadData(direction: direction, animated: animated)
    }

    public func removeController(_ controller: UIViewController, animated: Bool = true) {
        guard let index = controllers.index(of: controller) else {
            return
        }
        removeController(at: index, animated: animated)
    }

    public func removeCurrentController(animated: Bool = true) {
        removeController(at: _currentIndex.value, animated: animated)
    }

    private var previousIndexs: [Int] = [0]
    private var lastPendingIndex: Int = 0

    public var isScrollEnabled: Bool = true {
        didSet {
            pageViewController
                .view
                .subviews
                .compactMap { $0 as? UIScrollView}
                .forEach { $0.isScrollEnabled = isScrollEnabled }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        pageViewController.automaticallyAdjustsScrollViewInsets = false
        pageViewController.dataSource = self
        pageViewController.delegate = self

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageViewController.view.frame = view.bounds
    }

    private func reloadData(direction: UIPageViewController.NavigationDirection = .forward, animated: Bool = true) {
        guard _currentIndex.value >= 0 && _currentIndex.value < controllers.count else { return }
        let controller = controllers[_currentIndex.value]
        pageViewController.fixbug_setViewControllers([controller], direction: direction, animated: animated)
    }
}


// bug fix for uipageview controller. see http://stackoverflow.com/questions/14220289/removing-a-view-controller-from-uipageviewcontroller
// 参考 http://www.jianshu.com/p/3cca93ceee96
extension UIPageViewController {

    func fixbug_setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        setViewControllers(viewControllers, direction: direction, animated: animated) { [unowned self] finished in
            if finished && animated {
                DispatchQueue.main.async {
                    self.setViewControllers(viewControllers, direction: direction, animated: false, completion: nil)
                }
            }
            completion?(finished)
        }
    }
}

extension RxPageViewController: UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let index = controllers.index(of: viewController), index > 0 else {
            return nil
        }

        return controllers[index-1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let index = controllers.index(of: viewController), index < controllers.count-1 else {
            return nil
        }

        return controllers[index+1]
    }
}

extension RxPageViewController: UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let lastPendingController = pendingViewControllers.first else {return}
        guard let index = controllers.index(of: lastPendingController) else {return}
        lastPendingIndex = index
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {return}
        guard let previousController = previousViewControllers.first else {return}
        guard let previousIndex = controllers.index(of: previousController) else {return}
        previousIndexs.append(previousIndex)

        // 这种情况是，当你在一个页面上，快速往左滑动然后又往右滑动时，会产生。此时
        // func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController])
        // 只会调用一次
        if previousIndex == lastPendingIndex {
            let currentIndex = previousIndexs[previousIndexs.count-2]
            _currentIndex.accept(currentIndex)
        } else {
            let currentIndex = lastPendingIndex
            _currentIndex.accept(currentIndex)
        }
    }
}
