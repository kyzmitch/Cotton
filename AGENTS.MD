# Agent Rules

## Best practice to use GoF design patterns
* Use strategy design pattern when `switch` statement has more than 1 case & the handling in these cases is not short and trivial.

## Testing Framework Guidelines

When writing new unit tests use Swift Testing framework instead of XCTest.

### Linter
Use swiftlint rules for *.swift files. Project rules file is at `catowseriOS/.swiftlint.yml`.

### OOP
* Instead of creating static function for unrelated type, try to put that function as an extension of input/output type of that function or make that function as an instance function. This would help to follow encapsulation principle. If that function is beign used only in that file, then put type extension to that file only.