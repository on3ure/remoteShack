#!/usr/bin/env python
import keybow
import time


keybow.setup(keybow.MINI)

ptt = 0

rxselect = 0
pttbutton = 1
txselect = 2

@keybow.on()
def handle_key(index, state):
    global pttbutton
    global rxselect
    global txselecpttbuttonpttbuttont
    # check web for ptt button of on -> ptt to 1
    global ptt
    print("{}: Key {} has been {}".format(
        time.time(),
        index,
        'pressed' if state else 'released'))

    if state:
      if index == pttbutton :
        if ptt == 1 :
          keybow.set_led(index, 0, 0, 0)
          ptt = 0
        else:
          keybow.set_led(index, 255, 0, 0)
          ptt = 1
      
      if index == rxselect :
        if ptt == 0 :
          keybow.set_led(index, 0, 255, 0)
      if index == txselect :
        if ptt == 0 :
          keybow.set_led(index, 0, 0, 255)
    else:
      if index != pttbutton :
          keybow.set_led(index, 0, 0, 0)


while True:
    keybow.show()
    time.sleep(1.0 / 60.0)
