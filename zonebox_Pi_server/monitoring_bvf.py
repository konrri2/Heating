import datetime, threading
import requests
from bs4 import BeautifulSoup
import csv
import re  # regular expressions
from RoomClass import *
import os.path
import switcher_bvf


print("monitoring started")


url = 'http://192.168.1.8:8080/eindex.htm'
writes_in_hour_count = 0
last_observation = " "


def read_rooms_settings_file():
    try:
        global rooms_arr
        rooms_arr = []  # clear
        with open('./settings.csv', 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                rooms_arr.append(Room(row[0], row[1], row[2], row[3], float(row[4]), float(row[5]), float(row[6]), float(row[7])))
        print("read settings; number of rooms=" + str(len(rooms_arr)))
    except:
        print("cannot read settings file")


def remove_non_ascii(text):
    return ''.join(i for i in text if ord(i)<128)


def read_outside_temperature_from_page(row_array):
    try:
        meteo_page = requests.get('https://www.meteoprog.pl/pl/weather/Tarnowopodgorne/')
        beat_soup = BeautifulSoup(meteo_page.text, 'html.parser')
        span_temperature_value = beat_soup.find(class_='temperature_value')
        temp_val = span_temperature_value.contents[0]
        row_array.append(temp_val.replace("+", ""))
        icon_tooltip = beat_soup.find(class_=re.compile("^icon-weather"))
        # print(icon_tooltip['title'])
        weather_description = icon_tooltip['title']
        weather_description = weather_description.replace(",", ":")
        row_array.append(remove_non_ascii(weather_description))
    except:
        row_array.append("err")
        row_array.append("err")


def read_rooms_temp_to_csv_row():
    row_array = [datetime.datetime.now().strftime("%Y-%m-%d %H:%M")]
    read_outside_temperature_from_page(row_array)
    for room in rooms_arr:  # read all
        soup = switch_room_on_page(room.id_on_page)
        read_single_room_temp(soup, room)
        switcher_bvf.readjust_room_settings(room)
    row_array.append(" ")
    for room in rooms_arr:  # write temp
        row_array.append(room.current_temp)
    row_array.append(" ")
    for room in rooms_arr:
        row_array.append(room.set_temp)
    row_array.append(" ")
    for room in rooms_arr:
        row_array.append(str(room.is_on))
    row_array.append(" ")
    for room in rooms_arr:
        row_array.append(room.mode)
    return row_array


def csv_header_row():
    row_array = ["date time", "outside temp", "weather"]
    row_array.append("curr_temp")
    for room in rooms_arr:
        row_array.append(room.name)
    row_array.append("set_temp")
    for room in rooms_arr:
        row_array.append(room.name)
    row_array.append("is_on")
    for room in rooms_arr:
        row_array.append(room.name)
    row_array.append("mode")
    for room in rooms_arr:
        row_array.append(room.name)
    return row_array


def switch_room_on_page(room_id):
    # print("switching to room " + room_id)
    data = {'room': room_id}
    page = requests.post(url, data=data)
    soup = BeautifulSoup(page.text, 'html.parser')
    return soup


def read_single_room_temp(soup, room):
    try:
        # html_title = soup.find(id='title')
        # print("html_title=")
        # print(html_title)
        # html_cur_temp = soup.find(id='cur_temp')  # cannot find this because some funny characters (works on macbook though) soup.find(id='cur_temp')
        match = re.search('.......â\x84\x83', soup.text)
        html_cur_temp = match.group(0)
        cur_temp = html_cur_temp.replace(" ", "").replace("â\x84\x83", "")
        room.current_temp = cur_temp
        # set temp is hidden in javascript
        script = soup.findAll('script')[2].string
        m = re.search('stemp = [.0-9]{1,5};', script) # it doesent work if one number only
        stemp = m.group(0).replace(";", "")
        stemp_val = stemp.replace("stemp = ", "")
        room.set_temp = stemp_val
    except:
        print('cannot read temp from room ' + room.number_name)
    try:
        room.is_on = soup.find('input', attrs={'name': 'onoff', 'value': '1'}).has_attr('checked')
        if soup.find('input', attrs={'name': 'cmode', 'value': '0'}).has_attr('checked'):
            room.mode = "Comf"
        elif soup.find('input', attrs={'name': 'cmode', 'value': '1'}).has_attr('checked'):
            room.mode = "Econ"
        elif soup.find('input', attrs={'name': 'cmode', 'value': '4'}).has_attr('checked'):
            room.mode = "Auto"
        else:
            room.mode = "Error"
    except:
        print('cannot read radio buttons from room ' + room.number_name)


def write_csv(input_row, file_name):
    is_a_file = os.path.isfile(file_name)
    # print(is_a_file)
    with open(file_name, mode='a') as res_file:
        writer = csv.writer(res_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        if not is_a_file:
            writer.writerow(csv_header_row())
        writer.writerow(input_row)


def main_loop():
    global writes_in_hour_count
    global last_observation
    read_rooms_settings_file()
    try:
        csv_row = read_rooms_temp_to_csv_row()
        last_observation = ', '.join(csv_row)
        print("last_observation= " + last_observation)
        if writes_in_hour_count == 0:
            file_name_global = './res/all.csv'
            write_csv(csv_row, file_name_global)
        if writes_in_hour_count >= 12:
            writes_in_hour_count = -1  # so it starts from the begging
        file_name_date = datetime.datetime.now().strftime("%Y_%m_%d")
        file_name_date = './res/' + file_name_date + ".csv"
        write_csv(csv_row, file_name_date)
    except:
        print("!!!!    \n!\n! main loop error \n\n")
    writes_in_hour_count = writes_in_hour_count + 1
    threading.Timer(300, main_loop).start()  # every 5 minutes


main_loop()

