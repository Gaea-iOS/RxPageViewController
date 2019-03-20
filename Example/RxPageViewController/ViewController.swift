//
//  ViewController.swift
//  RxPageViewController
//
//  Created by wangxiaotao on 03/19/2019.
//  Copyright (c) 2019 wangxiaotao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import RxPageViewController

class ViewController: UIViewController {

    @IBOutlet weak var scrollToNextButton: UIButton!
    @IBOutlet weak var scrollToPreviousButton: UIButton!
    @IBOutlet weak var scrollToIndexButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!

    @IBOutlet weak var addControllerButton: UIButton!
    @IBOutlet weak var insertControllerButton: UIButton!
    @IBOutlet weak var removeControllerButton: UIButton!

    @IBOutlet weak var resetButton: UIButton!

    private let disposeBag = DisposeBag()

    @IBOutlet weak var holderView: UIView!

    private lazy var pageViewController: RxPageViewController = {
        let controller = childViewControllers.first as! RxPageViewController
        controller.view.backgroundColor = .black
        return controller
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        scrollToNextButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.pageViewController.scrollToNext()
            })
            .disposed(by: disposeBag)

        scrollToPreviousButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.pageViewController.scrollToPrevious()
            })
            .disposed(by: disposeBag)

        scrollToIndexButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.pageViewController.scrollToIndex(index: 2)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            pageViewController.currentIndex,
            pageViewController.totalPages
            )
            .map { String("currentIndex = \($0.0), totalPages = \($0.1)") }
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)


        addControllerButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.pageViewController.addController(self.controller())
            })
            .disposed(by: disposeBag)

        insertControllerButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.pageViewController.insertController(self.controller(), at: 2)
            })
            .disposed(by: disposeBag)

        removeControllerButton.rx
            .tap
//            .withLatestFrom(pageViewController.currentIndex)
            .subscribe(onNext: { [unowned self] in
                self.pageViewController.removeController(at: 1)
            })
            .disposed(by: disposeBag)

        resetButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.pageViewController.reset()
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private var i = 0
    func controller() -> UIViewController {
        let colors: [UIColor] = [.red, .yellow, .blue, .purple, .cyan]
        let controller1 = UIViewController()
        controller1.view.backgroundColor = colors[i]
        i = (i + 1) % colors.count
        return controller1
    }
}

