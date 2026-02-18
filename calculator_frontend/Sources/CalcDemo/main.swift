import Foundation
import Calculator
let calc = Calculator()
print("calc-demo: 2+3=\(calc.add(2,3))")
// long-running to allow lifecycle validation
while true { sleep(3600) }
