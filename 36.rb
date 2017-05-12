#!/usr/bin/ruby
# Project Euler 36

# The decimal number, 585 = 10010010012 (binary), is palindromic in both bases.

# Find the sum of all numbers, less than one million, which are palindromic in
# base 10 and base 2.

# (Please note that the palindromic number, in either base, may not include
# leading zeros.)

# Handle the palindromic method again brute force
def palindromic?(i)
  i.to_s == i.to_s.reverse
end

i = 0

total = 0

while i < 1_000_000
  total += i if palindromic?(i) && palindromic?(i.to_s(2))
  i += 1
end

p total

# answer is 872187

# If I wasn't doing this in ruby (and ruby's kinda a pain with)