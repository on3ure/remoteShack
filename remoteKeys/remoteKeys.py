#!/usr/bin/env python3
import keybow
import time
import requests
import redis


pttON_URL = "http://172.16.30.76/2/low"
pttOFF_URL = "http://172.16.30.76/2/high"
cwURL = "http://172.16.30.76/rotate/cw"
ccwURL = "http://172.16.30.76/rotate/ccw"

ptt = 0

cwselect = 0
pttbutton = 1
pttlight = 0
ccwselect = 2

keybow.setup(keybow.MINI)
redis = redis.Redis(host='localhost', port=6379, db=0)


@keybow.on()
def handle_key(index, state):
    global pttbutton
    global cwselect
    global ccwselect
    global ptt

    if state:
        if index == pttbutton:
            if ptt == 1:
                try:
                    requests.get(url=pttOFF_URL, timeout=1)
                except requests.exceptions.RequestException as e:  # This is the correct syntax
                    print(e)
                ptt = 0
            else:
                try:
                    requests.get(url=pttON_URL, timeout=1)
                except requests.exceptions.RequestException as e:  # This is the correct syntax
                    print(e)
                ptt = 1

        if index == cwselect:
            keybow.set_led(index, 0, 0, 255)
            try:
                requests.get(url=cwURL, timeout=1)
            except requests.exceptions.RequestException as e:  # This is the correct syntax
                print(e)
        if index == ccwselect:
            keybow.set_led(index, 0, 0, 255)
            try:
                requests.get(url=ccwURL, timeout=1)
            except requests.exceptions.RequestException as e:  # This is the correct syntax
                print(e)
    else:
        if index != pttbutton:
            keybow.set_led(index, 0, 0, 0)


while True:
    keybow.show()
    if redis.get('ptt'):
        if pttlight == 0:
            keybow.set_led(pttbutton, 255, 0, 0)
            pttlight = 1
            ptt = 1
    else:
        if pttlight == 1:
            keybow.set_led(pttbutton, 0, 0, 0)
            pttlight = 0

    time.sleep(1.0 / 120.0)
