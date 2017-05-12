#!/usr/bin/ruby
# Project Euler 112

# Working from left-to-right if no digit is exceeded by the digit to its left it
# is called an increasing number; for example, 134468.
# Similarly if no digit is exceeded by the digit to its right it is called a
# decreasing number; for example, 66420.
#
# We shall call a positive integer that is neither increasing nor decreasing a
# "bouncy" number; for example, 155349.
#
# Clearly there cannot be any bouncy numbers below one-hundred, but just over
# half of the numbers below one-thousand (525) are bouncy.
# In fact, the least number for which the proportion of bouncy numbers first
# reaches 50% is 538.
#
# Surprisingly, bouncy numbers become more and more common and by the time we
# reach 21780 the proportion of bouncy numbers is equal to 90%.
#
# Find the least number for which the proportion of bouncy numbers is exactly
# 99%.


# This is an easy to do brute force solve here. I was actually surprised that
# I could do it in like 15 minutes.
def bouncy(x)
  # split the digits up into individual strings to sort
  all_digits = x.to_s.split('').map(&:to_i)

  # so, we go left to right (sort all digits) and then right to left using
  # .reverse to handle the second case (decreasing numbers).
  # The key
  all_digits.sort != all_digits && all_digits.sort.reverse != all_digits
end

i = 0
bouncy_number = 0
non_bouncy_number = 0
percentage = 0

while percentage < 0.99
  i += 1
  bouncy(i) ? bouncy_number += 1 : non_bouncy_number += 1
  percentage = bouncy_number / (bouncy_number + non_bouncy_number).to_f
end

p i

# answer: 1587000
