import UIKit

/** Defining a function
 */
func greetUser() {
    print("Hello, welcome to the app!")
}

// Calling a function
greetUser() // Prints "Hello, welcome to the app!"









/** Function with parameters */
func greetUserByName(name: String) {
    print("Hello, \(name)!")
}
greetUserByName(name: "Marina") // Calls the function with an argument

// Function with a return value
func createGreeting(name: String) -> String {
    return"Hello, \(name)!"
}






/**The Billion-Dollar Mistake: Optionals**/
var middleName: String? = "Mama"// The '?' makes it an Optional String
print(middleName ?? "") // Output: Optional("Mama")


let message = createGreeting(name: "Sothea") // message holds "Hello, Sothea!"
print(message)




/** Unwrapping Optionals Safely*/

var possibleNumber: String? = "42"

if let actualNumber = possibleNumber {
    // This code only runs if possibleNumber is NOT nil
    print("The number is \(actualNumber).") // 'actualNumber' is a String, not an Optional
} else {
    print("The number is missing.")
}
// 'actualNumber' does not exist out here.




/**Collections: Arrays*/
// Creating Arrays
var shoppingList: [String] = ["Eggs", "Milk", "Bread"]
var scores = [92, 85, 97] // Type inferred as [Int]
// Accessing & Modifying
print(shoppingList[0]) // "Eggs"
shoppingList.append("Apples") // Adds to the end
shoppingList[1] = "Almond Milk"// Replaces "Milk"
print(shoppingList.count) // 4
print(shoppingList.dropFirst())






/**Collections: Dictionaries*/
// Creating a Dictionary [Key: Value]
var userDictionary: [String: String] = [
    "name": "Nem Sothea",
    "email": "nemsothea13@gmail.com",
    "password": "qwer1234@"
]
// Accessing & Modifying
print(userDictionary["name"]!) // "Nem Sothea" (Force-unwrap - careful!)
userDictionary["theme"] = "Dark"// Adds a new key-value pair
let email = userDictionary["email"] // email is an Optional String (String?)
print(userDictionary)  //["email": "nemsothea13@gmail.com", "name": "Nem Sothea", "password": "qwer1234@", "theme": "Dark"]
