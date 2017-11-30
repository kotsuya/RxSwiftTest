//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by YooSeunghwan on 2017/11/30.
//  Copyright © 2017年 YooSeunghwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    enum State : Int {
        case useButtons
        case useTextField
    }

    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var greetingsTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet var greetingButtons: [UIButton]!
    
    let lastSelectedGreeting: Variable<String> = Variable("Hello")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameObservable: Observable<String?> = nameTextField.rx.text.asObservable()
        let customGreetingObservable: Observable<String?> = greetingsTextField.rx.text.asObservable()
        
        let greetingWithNameObservable: Observable<String> = Observable.combineLatest(nameObservable, customGreetingObservable) { (str1: String?, str2: String?) in
            return str1! + ", " + str2!
        }
        
        greetingWithNameObservable.bind(to: greetingsLabel.rx.text).disposed(by:disposeBag)
        
        let segmentedControlObservable: Observable<Int> = stateSegmentedControl.rx.value.asObservable()
        let stateObservable: Observable<State> = segmentedControlObservable.map { (selectedIndex: Int) -> State in
            return State(rawValue: selectedIndex)!
        }
        
        let greetingTextFieldEnabledObservable: Observable<Bool> = stateObservable.map { (state: State) -> Bool in
            return state == .useTextField
        }
        
        let buttonsEnabledObsevable: Observable<Bool> = greetingTextFieldEnabledObservable.map {
            (greetingEnabled: Bool) -> Bool in
            return !greetingEnabled
        }
        
        greetingButtons.forEach { button in
            buttonsEnabledObsevable.bind(to: button.rx.isEnabled).disposed(by: disposeBag)
            button.rx.tap.subscribe(onNext: { (nothing: Void) in
                self.lastSelectedGreeting.value = button.currentTitle!
            }).disposed(by: disposeBag)
        }
        
        let predefinedGreetingObservable: Observable<String> = lastSelectedGreeting.asObservable()
        predefinedGreetingObservable.subscribe(onNext: {
            (string: String) in
            print(string)
        }).disposed(by: disposeBag)
        
        let finalGreetingObservable: Observable<String> = Observable.combineLatest(stateObservable, customGreetingObservable, predefinedGreetingObservable, nameObservable) {
            (state: State, customGreering: String?, predefinedGreeting: String?, name: String?) in
            switch state {
            case .useButtons: return predefinedGreeting! + ", " + name!
            case .useTextField: return customGreering! + ", " + name!
            }
        }
        finalGreetingObservable.bind(to: greetingsLabel.rx.text).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

