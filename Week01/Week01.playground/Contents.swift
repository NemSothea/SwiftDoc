import UIKit

var greeting = "Hello, playground"
print(greeting)

/**
 Storing Data - Variables & Constants
 */

// This is a comment. The computer ignores it.
// A variable: its value can vary.

var myName = "Pisey"
myName = "Pisey Jo"// This is allowed.

// A constant: its value is constant.
let birthYear = 2000
// birthYear = 2001 // This would cause an ERROR!


/**
 Data Types
 */


let message: String = "Hello World"// Explicit type annotation

let score = 1000 // Inferred as Int
let pi = 3.14 // Inferred as Double
let isLoggedIn = true // Inferred as Bool


/**
 Operators
 */

let a = 10
let b = 3
let sum = a + b// 13
let isGreater = a > b// true
print(isGreater)
var counter = 0
counter += 1// counter is now 1


/**
 Control Flow - Making Decisions
 */


let temperature = 70
if temperature > 80 {
    print("It's hot outside!") // This won't run
} else if temperature > 60 {
    print("It's nice outside!") // This WILL run
} else {
    print("It's a bit chilly.")
}
