//: Playground - noun: a place where people can play

import UIKit
import Foundation
import PlaygroundSupport

// No need to import swift files. They are in global State. Frameworks e.g. from Cocoapods still need to be imported. e.g. by using import Alamofire


// MARK: Const / Var
let cantChangeThis = "constant. type string is inferred"
var canChangeThis = "variable"
canChangeThis = "obviously"

// MARK: Optionality
var canChangeThisButItMightBeNil: String? = "Optionality not inferrable"
var orInitiallyNilForLaterChange: String?
if true {
    orInitiallyNilForLaterChange = "e.g. only not nil if some condition is fulfilled"
}
var haveToChangeThis: String! // ! => work with it as if it can never be nil.
/*
but actually it is currently still nil => before we do anything with it we have to fill it
one case that comes to my mind is: @IBOutlet views in VC.
they are nil on initialization
 => instance property could be @IBOutlet var viewFromStoryBoard: UIView!, but on VC you follow the viewController lifecycle and usually don't do anything before viewDidLoad anyway (because - duh - until then the view is not loaded, so no UI changes can be done anyway)
 After viewDidLoad, the @IBOutlets will be filled with the corresponding outlets of the storyboard.
 => `IBOutlet var viewFromStoryBoard: UIView!` is nil on initialization of your VC, but will be set before any UI relevant logic can be performed.

 Setting @IBOutlet var viewFromStoryBoard: UIView (no exclamation point) will result in the compiler to enforce that the viewFromStoryBoard is not nil on instantiation => won't compile.
*/
haveToChangeThis = "pew, out of the danger zone"
haveToChangeThis.count // would crash if it was nil


// MARK: Unwrapping
var mightBeNil: String?

if let pewNotNil = mightBeNil {
    print("mightBeNil is not nil, and we can use it as pewNotNil that now has type String, not String?" + pewNotNil)
    // pewNotNil will only "live" in this scope
} else {
    print("mightBeNil is nil")
}

// to do early returns / follow the golden path, there's guard, which is basically a inverse if let.
guard let makeSureThisIsNotNil = canChangeThisButItMightBeNil else {
    print("mightBeNil is nil")
    // makeSureThisIsNotNil DOES NOT LIVE IN THIS SCOPE
    // actually the compiler forces you to quit the current scope e.g. by doing return
    abort()
}
// BUT HERE, so we can do this without crashes
print(makeSureThisIsNotNil.count)

// we can actually also enforce any other condition during an if let AND even combine several lets
if let pewNotNilAgain = mightBeNil, let _ = canChangeThisButItMightBeNil,  pewNotNilAgain.count == 4 {
    print("pewNotNilAgain has 4 characters. ")
    // we also checked canChangeThisButItMightBeNil for being nil, and would make it accessible - which we don't need, so we use the _ as a dumpster. The compiler respects the dumpster ;)
}

// Now if we just want to do basic operations and not have many many if lets, we can do optional chaining
mightBeNil?.count // will either print the text length, or nil if mightBeNil is nil => the count operation would not be performed then

mightBeNil = "making sure this is not nil"
mightBeNil!.count // will always try to perform the count function as mightBeNil is treated as never being able to be nil. => THIS IS VERY DANGEROUS and actially crashes here.

// MARK: Enums & Errors

enum Region: String {
    case de = "Germany"
    case NL = "Netherlands"
}

print("\(Region.de.rawValue) will be printed as Germany inline.") // the compiler is quite smart at inferring, ofthen you could also remove the "Region" before de.rawValue

// Now enums are used for Errors like this
enum SomeError: Error {
    case yepThatHappened
    case somethingElseHappened
}
func doSth() throws {
    throw SomeError.yepThatHappened
}

// try catch
do {
    try doSth()
} catch let error {
    // the thrown error is available as error here - and is an enum value so we can switch
    switch error {
    case SomeError.yepThatHappened:
        print("it happened!")
    case SomeError.somethingElseHappened:
        print("not that one")
    default:
        print("it can also be some other regular Error case that we didnt define though")
    }
}

// notice for enum switches: compiler enforces to handle every possible case OR use the default case


// Structs

protocol Fruit {
    var name: String { get } // can't change that anymore => getter only
    var picking: (colorOnPickTime: UIColor, pickTime: Date)? { get set }  // custom tuple
}

// structs are like classes, but basically on change the instance gets copied and the original memory ref stays the same - you'll see later
// structs can also inherit or implement protocols (interfaces)
struct Apple: Fruit {
    
    var name: String
    var picking: (colorOnPickTime: UIColor, pickTime: Date)? = nil
    
    // basic computed getter
    var color: UIColor? {
        // let's have a function that determines the current color of the apple based on the color when it was picked
        guard let picking = self.picking else {
            // not picked yet
            return nil
        }
        
        let timeSincePicked = -picking.pickTime.timeIntervalSinceNow
        let brightnessFactor: Double = 1.0 - (timeSincePicked / 20)
        
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        picking.colorOnPickTime.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)  // there are still pointers for some C apis
        
        let newBrightness = brightness * CGFloat(brightnessFactor)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
}

// now let's do a story

// We found an apple on the tree, it enters our universe (notice how 1. we can write Apple( instead of Apple.init(, and 2. how this whole initializer is autogenerated. Only works for structs)
let untouchableApple = Apple(name: "The most beautiful round apple", picking: nil)
// now unfortunately he can't be picked because it can't be changed (let).
// but we have a magic device that we can use to clone and pick it like this
var appleClone = untouchableApple
// now we can pick it
appleClone.picking = (colorOnPickTime: .red, pickTime: Date())   // Compiler infers .red as beign
// What a beautiful apple. Unfortunately over time it will loose it's beauty.

// MARK: Threading

// let's watch the apple slowly become old
let dispatchQueue = DispatchQueue.global()
dispatchQueue.async {
    for _ in 0...60 {
        appleClone.color
        sleep(1)
    }
}

// Now we have some apples and throw them away at different times.
let appleWatchingGroup = DispatchGroup()

DispatchQueue.global().async {
    let greenApple = Apple(name: "Green Apple", picking: (colorOnPickTime: .green, pickTime: Date()))
    appleWatchingGroup.enter() // start watching the green apple
    for _ in 0...20 {    // _ ignored property
        greenApple.color
        sleep(1)
    }
    appleWatchingGroup.leave() // throw the apple away
}
DispatchQueue.global().async {
    let blueApple = Apple(name: "Blue Apple", picking: (colorOnPickTime: .blue, pickTime: Date()))
    appleWatchingGroup.enter() // start watching the blue apple
    for _ in 0...15 {
        blueApple.color
        sleep(1)
    }
    appleWatchingGroup.leave() // throw the apple away
}

appleWatchingGroup.notify(queue: DispatchQueue.global()) {
    print("all apples have been thrown away")
    // the blue one actually didnt look to bad yet
}


// MARK: Extensions
// Let's assume the class `Apple` was provided by iOS and is quite basic. In our context, we also want to be able to know the age. Well we could subclass apples and implement a new age property. But it's even nicer to just extend the Apple capabilities like this

extension Apple {
    
    var timeSincePicked: TimeInterval? {
        guard let picking = self.picking else { return nil }
        return Date().timeIntervalSince(picking.pickTime)
    }
    
    // or even create new initializers for insta-find-and-pick
    init(name: String, color: UIColor) {
        self.init(name: name, picking: (colorOnPickTime: color, pickTime: Date()))
    }
    
}

// Extensions can also be used for structuring
protocol Paintable {
    mutating func paint(with color: UIColor)
}

struct Chair {
    var color: UIColor = .green
    // Here we can do all the core non-interfaced logic.
    // properties, inits etc
}

extension Chair: Paintable {
    mutating func paint(with color: UIColor) {
        self.color = color
    }
}

// so we can create chairs and paint them
var chair = Chair(color: .blue)
// we don't like blue anymore
chair.paint(with: .red)

// Arrays & Dicts
// are simple

let stringArray = ["test", "123"] // inferred type [String]
let optionalStringArray: [String]? = ["test", "123"]  // array is optional
let optionalValueArray: [String?] = ["test", nil, "123"] // items in array are optional

let dict = ["someKey": "someValue"] // inferred type [String: String]
let dict2: [Int: String] = [1: "someValue"] // keys can be anything (as long as the key is hashable = AnyHashable)
let literallyAnything: [AnyHashable: Any] = [1: "testValue", "testKey": appleClone] // and therefore also mixed. That's what a dict from JSON complies to.

let jsonString = "{'a': 'b', 'sub': {'dub': 'wub'}}"


// MARK: blocks
// blocks are the same as functions, they can be stored in properties, passed in params etc.
func multiplyFunc(_ a: Int, _ b: Int) -> Int { return a*b }
var multiplyBlock: ((_ a: Int, _ b:Int) -> Int) = { (a, b) in
    return a*b
}

multiplyFunc(3, 7)
multiplyBlock(3, 7)

var mVar = multiplyFunc
var mVarBlock = multiplyBlock

mVar(3,8)
mVarBlock(3,8)

func performOperation(a: Int, b: Int, operationBlock: ((Int, Int)->Int)) -> Int {
    return operationBlock(a, b)
}

performOperation(a: 4, b: 9, operationBlock: multiplyFunc)
performOperation(a: 4, b: 9, operationBlock: multiplyBlock)
performOperation(a: 4, b: 9, operationBlock: { (a,b) in a*b })

// Now actually we can put any int,int -> int operation there
performOperation(a: 1000, b: 6, operationBlock: { (x,y) in return x%y })

// now ((Int, Int)->Int) is ugly and the whole function doesnt look swifty
typealias IntsToInt = ((Int, Int)->Int)

extension Int {
    func perform(_ operation: IntsToInt, with operand: Int) -> Int {
        return operation(self, operand)
    }
}

9.perform(multiplyBlock, with: 17)  // That's not really nicer than 9*17

// MARK: Setter Getter

print("\n\n===MY HOUSE===\n")

protocol HouseDailyRoutineInterface {
    mutating func lock(locked: Bool)
    mutating func openWindow()
}

struct House: HouseDailyRoutineInterface {
    
    // nested struct / object
    private class AlarmSystem {
        
        // booting the alarm takes quite a long time
        init() {
            print("🛡 Alarm system is booting...")
            sleep(1)
            print("🛡 Alarm system is ready to go")
        }
        
        var isActive: Bool = false {
            didSet {
                if isActive {
                    print("🛡 Alarm activated")
                } else {
                    print("⚠️ Alarm deactivated")
                }
            }
        }
        
        func 🚨() {
            print("🚨 BREAK IN ALERT 🚨")
        }
    }
    
    init() {
        print("House is set up")
    }
    
    // computed setter / getter
    private var alarmActive: Bool {
        mutating get {
            return alarmSystem.isActive
        }
        set {
            alarmSystem.isActive = newValue
        }
    }
    
    // instantiate the alarmsystem lazy and only once
    private lazy var alarmSystem: AlarmSystem = {
        return AlarmSystem()
    }()

    
    // will set / did set with initial value = false
    private var locked: Bool = false {
        willSet {
            autoCloseAllWindowsAndDoors()
        }
        didSet {
            alarmActive = true
        }
    }
    
    private var allWindowsClosed: Bool = true {
        didSet {
            if allWindowsClosed == false && self.alarmActive {
                alarmSystem.🚨()
            }
        }
    }
    
    mutating func lock(locked: Bool) {
        self.locked = locked
        print("\(locked ? "locked" : "unlocked") the house")
    }
    
    mutating func openWindow() {
        print("opening a window")
        allWindowsClosed = false
    }
    
    mutating private func autoCloseAllWindowsAndDoors() {
        allWindowsClosed = true
        print("locked all doors and windows")
    }
    
    // default value for reply block
    func ringDoorbell(reply: (()->())? = nil) {
        print("🔔 RING RING")
        if locked {
            return
        }
        reply?()
    }
}

// now the story. This is my house (but for my daily routine, i don't need to know how to e.g. ring the doorbell, just what i actually need - lock/unlock/window opening. = HouseInterface
var myHouse = House()
var dailyRoutineHouse = myHouse as HouseDailyRoutineInterface // myHouse is therefore actually of type: HouseInterface (in objc: id<HouseInterface>. Casting here is not a problem, the compiler knows that my house implements this interface so it can never go wrong.
// in the morning, I take a shower and open a window
dailyRoutineHouse.openWindow()
// Afterwards I leave my house and lock the doors (windows and other doors then close automatically)
dailyRoutineHouse.lock(locked: true)

// oh no an evil burglar is walking by and he doesnt care about the daily routine aspect of the house, he sees it for what it is. An opportunity.
// he rings the doorbell to see if i'm home
// myHouse.ringDoorbell() would be a valid call as well but our burglar is more sophisticated

let burglarGroup = DispatchGroup()

burglarGroup.enter()
var anyoneHome = false
myHouse.ringDoorbell {
    anyoneHome = true
    burglarGroup.leave()
}
burglarGroup.wait(timeout: .now()+5)   // burglar waits for 5 sec for any response
burglarGroup.notify(queue: DispatchQueue.global()) {
    if anyoneHome {
        // leave quickly, the owner is home
        return
    }
    myHouse.openWindow()
}


/*
 
 Notice in the console:
 
 House is set up
 opening a window
 🛡 Alarm system is booting...
 🛡 Alarm system is ready to go
 locked all doors and windows
 🛡 Alarm activated
 locked the house
 opening a window
 🚨 BREAK IN ALERT 🚨
 
 The alarm system is only set up after opening a window - not on initialization of my house = lazy var
 
 */
print("\n\n=== Burglar routine ===\n")


// the burglar wants to reuse this process for any house, so perfect opportunity to store it as a process in his mind (a function would do the same and would be more readable - but we'll make a block anyway)
let checkBurglable: (House, @escaping (Bool)->())->() = { (victimsHouse, burglabilityCallback) in // escaping means that this block can run in a different thread than the original one
    let burglarGroup = DispatchGroup()
    burglarGroup.enter()
    var burglable = true
    myHouse.ringDoorbell {
        burglable = false
        burglarGroup.leave()
    }
    burglarGroup.wait(timeout: .now()+5)   // burglar waits for max 5 sec for any response
    burglarGroup.notify(queue: DispatchQueue.global()) {
        return burglabilityCallback(burglable)
    }
}


// so whenever he finds a house, he can run his routine
var someHouse = House()
checkBurglable(someHouse) { burglable in
    someHouse.openWindow()
}
/*
oh no, seems like the house owner forgot to activate his alarm system, so the burglar got in before

 === Burglar routine ===
 
 House is set up
 opening a window
 🛡 Alarm system is booting...
 🛡 Alarm system is ready to go
 */


PlaygroundPage.current.needsIndefiniteExecution = true

