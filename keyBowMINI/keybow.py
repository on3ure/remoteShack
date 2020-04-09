#!/usr/bin/env python3
import keybow
import time
import requests


keybow.setup(keybow.MINI)

ptt = 0

rxselect = 0
pttbutton = 1
txselect = 2

pttON_URL = "http://172.16.30.76/2/low"
pttOFF_URL = "http://172.16.30.76/2/high"
rxURL = "http://172.16.30.76/receive/next"
txURL = "http://172.16.30.76/transmit/next"


@keybow.on()
def handle_key(index, state):
    global pttbutton
    global rxselect
    global txselect
    global ptt

    # check web for ptt button of on -> ptt to 1
    # TODO !!!!

    if state:
        if index == pttbutton:
            if ptt == 1:
                keybow.set_led(index, 0, 0, 0)
                try:
                    requests.get(url=pttOFF_URL, timeout=1)
                except requests.exceptions.RequestException as e:  # This is the correct syntax
                    print(e)
                ptt = 0
            else:
                keybow.set_led(index, 255, 0, 0)
                try:
                    requests.get(url=pttON_URL, timeout=1)
                except requests.exceptions.RequestException as e:  # This is the correct syntax
                    print(e)
                ptt = 1

        if index == rxselect:
            if ptt == 0:
                keybow.set_led(index, 0, 255, 0)
                try:
                    requests.get(url=rxURL, timeout=1)
                except requests.exceptions.RequestException as e:  # This is the correct syntax
                    print(e)
        if index == txselect:
            if ptt == 0:
                keybow.set_led(index, 0, 0, 255)
                try:
                    requests.get(url=txURL, timeout=1)
                except requests.exceptions.RequestException as e:  # This is the correct syntax
                    print(e)
    else:
        if index != pttbutton:
            keybow.set_led(index, 0, 0, 0)


while True:
    keybow.show()
    time.sleep(1.0 / 60.0)
