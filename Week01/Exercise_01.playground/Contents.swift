import UIKit

/**
 Let's code together in our Playground!
    Create a constant name and a variable age.
    Assign them values.
    Print a message that says: "[name] is [age] years old."
    Write an if statement that checks if the person can vote (age >= 18) and prints "Can vote" or "Can't vote".
*/

//  Solution to Exercise 1
var name:String?
name = nil


var age = 27

print("\(name) is \(age) years old.")
// This is called string interpolation. It lets you put variables inside strings.
if age >= 18 {
    print("Can vote")
} else {
    print("Can't vote")
}


