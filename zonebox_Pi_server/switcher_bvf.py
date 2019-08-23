import datetime, threading
import requests
from bs4 import BeautifulSoup
import re  # regular expressions
from RoomClass import *
from enum import Enum
import math


class CMode(Enum):
    Comfort = 0
    Economy = 1
    Auto = 4


url = 'http://192.168.1.8:8080/eindex.htm'


def switch_room_on_page(room):
    print("switching to " + room.name + ": room " + room.id_on_page)
    data = {'room': room.id_on_page}
    page = requests.post(url, data=data)
    soup = BeautifulSoup(page.text, 'html.parser')
    return soup


def switch_mode(mode, room=None):  # room = None (null) means -> do not switch room, change current
    if room is not None:
        switch_room_on_page(room)
    print("switching mode " + mode.name)
    data = {'cmode': mode.value}
    page = requests.post(url, data=data)
    soup = BeautifulSoup(page.text, 'html.parser')
    return soup


def set_temp(temp_val, room=None):
    if room is not None:
        switch_room_on_page(room)
    print("setting temperature " + str(temp_val))
    # data = {'update_v0.settemp.value': temp_val}
    data = {'settemp': temp_val}
    page = requests.post(url, data=data)
    soup = BeautifulSoup(page.text, 'html.parser')
    return soup


# onoff 1 or 0
def set_thermostat_on(onoff, room=None):
    if room is not None:
        switch_room_on_page(room)
    print("setting thermostat on=" + str(onoff))
    data = {'onoff': onoff}
    page = requests.post(url, data=data)
    soup = BeautifulSoup(page.text, 'html.parser')
    return soup


def readjust_room_settings(room):
    try:
        bvf_set_temp = float(room.set_temp)
        daytime_in_minutes = (datetime.datetime.now().hour * 60) + datetime.datetime.now().minute
        is_electricity_cheap = is_night_time_electricity()
        temp_to_set = 19.0
        if is_electricity_cheap:
            temp_to_set = calc_heating_temp(daytime_in_minutes, room)
        else:
            temp_to_set = calc_cooling_temp(daytime_in_minutes, room)
        if bvf_set_temp != temp_to_set:
            room.set_temp = room.set_temp + "->" + str(temp_to_set)
            set_temp(temp_to_set, room)
    except Exception as e:
        print(e)
        print("error while setting room " + room.name)


def is_night_time_electricity():
    h = datetime.datetime.now().hour
    if 6 <= h < 22:
        return False
    else:
        return True


def calc_heating_temp(daytime_in_minutes, room):
    t = 0  # time of heating in minutes (x in the linear function)
    if daytime_in_minutes > (22*60):
        t = daytime_in_minutes - (22*60)
    else:
        t = daytime_in_minutes + (2*60)
    # y = a*x + b
    y = room.calc_heating_a_factor() * t + room.temp_at_22_heating
    return round_temp(y)


def calc_cooling_temp(daytime_in_minutes, room):
    t = daytime_in_minutes - (6*60)
    y = room.calc_cooling_a_factor() * t + room.temp_at_6_cooling
    return round_temp(y)


# thermostats accepts temperature only in 0.5 steps
def round_temp(temp):
    t = (2.0*temp)
    ceiling = math.floor(t+0.2)
    res_t = float(ceiling) / 2.0
    return res_t


def tests():
    # tests
    # office = rooms_arr[7]
    # switch_mode(office, CMode.Comfort)
    # set_temp(13.5, office)
    # set_thermostat_on(1)
    # livingRoom = rooms_arr[5]
    # set_thermostat_on(0, livingRoom)

    room_test = Room("0", "main bedroom", "room1", "xxxx", 19.0, 17.5, 18.0, 22.0)
    minutes = 6.5*60.0
    #  temp = calc_heating_temp(minutes, room_test)
    temp = calc_cooling_temp(minutes, room_test)
    print("temp= " + str(temp))
    room_test.set_temp = room_test.set_temp + "->" + str(19.0)
    print("room_test.set_temp=" + room_test.set_temp)


# tests()
