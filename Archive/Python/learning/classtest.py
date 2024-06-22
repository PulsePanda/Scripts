import random
import os
import sys

class TestClass:
    __name = ""
    __height = 0
    __weight = 0
    __sound = 0
    test = ""

    def __init__(self, name, height, weight, sound):
        self.__name = name
        self.__height = height
        self.__weight = weight
        self.__sound = sound

    def __init__(self):
        name = ""

    def set_name(self, name):
        self.__name = name

    def get_name(self):
        return self.__name

test = TestClass()
test.set_name("test")
print(test.get_name())
