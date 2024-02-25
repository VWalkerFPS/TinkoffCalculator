//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Dmitrii on 31.01.2024.
//

import UIKit

let ERROR_LABLE_TEXT = "Ошибка!"

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
            case .add: return number1 + number2
            case .substract: return number1 - number2
            case .multiply: return number1 * number2
            case .divide:
                if number2 == 0 {
                    throw CalculationError.dividedByZero
                }
                return number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {
    
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [Calculation] = []
    let calculationHistoryStorage = CalculationHistoryStorage()
//    var lastResult = "NoData"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resetLabelText()
        historyButton.accessibilityIdentifier = "historyButton"
        
        calculations = calculationHistoryStorage.loadHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        
        if buttonText == "," && label.text?.contains(",") == true {
            return
        }
        
        if (label.text == "0" || label.text == ERROR_LABLE_TEXT ) && buttonText == "," {
            label.text = "0,"
            return
        }
        
        if label.text == "0" || label.text == ERROR_LABLE_TEXT{
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard 
            let buttonText = sender.currentTitle,
            let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabelText()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        
        resetLabelText()
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            
            label.text = numberFormatter.string(from: NSNumber(value: result))
            let newCalculation = Calculation(expression: calculationHistory, result: result, date: Date())
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
//            lastResult = label.text ?? "NoData"
        } catch {
            label.text = ERROR_LABLE_TEXT
        }
        
        calculationHistory.removeAll()
    }
    
    
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationListVC = sb.instantiateViewController(withIdentifier: "CalculationsListViewController")
        if let vc = calculationListVC as? CalculationListViewController {
            vc.calculations = calculations
        }
        
        navigationController?.pushViewController(calculationListVC, animated: true)
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet var historyButton: UIButton!
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard case .operation(let operation) = calculationHistory[index],
                  case .number(let number) = calculationHistory[index + 1]
            else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
    
    func resetLabelText() {
        label.text = "0"
    }
}

