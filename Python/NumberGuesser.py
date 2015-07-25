minNumber = int(input("What is the lower limit to our game? "))
maxNumber = int(input("What is the upper limit of our game? "))
currentNumber = int((maxNumber - minNumber) // 2)
previousNumber = maxNumber
guesses = 0
print("Thank you. Press 1 for higher, 2 for lower, and 3 for correct.")
guessed = False;

while(guessed == False):
	print("My guess: ")
	print(currentNumber)
	guesses += 1
	difference = int((currentNumber - previousNumber) / 2)
	difference = abs(difference)
	previousNumber = currentNumber
	result = int(input("Was I too high <1>, too low <2>, or was I right <3>? "))
	if result == 1:
		currentNumber -= difference
	if result == 2:
		currentNumber += difference
	if result == 3:
		guessed = True

print("Your number was ")
print(currentNumber)
print("I got your number in this many guesses: ")
print(guesses)
print("That was fun, thanks for playing!")