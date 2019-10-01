#!flask/bin/python
from flask import Flask, jsonify, request, send_from_directory
import os.path
from datetime import datetime, timedelta
import monitoring_bvf
import datetime
from RoomClass import *
import switcher_bvf

app = Flask(__name__)


@app.route('/')
def index():
    return "Hello, World!"


app = Flask(__name__)


@app.route('/api/all', methods=['GET'])
def get_file():
    print("/api/all")
    return send_from_directory('./res', 'all.csv')
    # app.send_file('/measurements_format.csv', attachment_filename='measurements_format.csv')
    # return send_from_directory(directory=uploads, filename='measurements_format.csv')


@app.route('/api/getSettings', methods=['GET'])
def get_settings():
    print("/api/getSettings")
    return send_from_directory('./', 'settings.csv')


@app.route('/api/today', methods=['GET'])
def get_today_csv():
    print("/api/today")
    file_name_date = datetime.datetime.now().strftime("%Y_%m_%d")
    return send_from_directory('./res', file_name_date+'.csv')


@app.route('/api/24h', methods=['GET'])
def get_2days_csv():
    print("/api/24h")
    yesterday = datetime.datetime.now() - timedelta(days=1)
    print(yesterday)
    file_name_date = datetime.datetime.now().strftime("%Y_%m_%d") + '.csv'
    file_yesterday = yesterday.strftime("%Y_%m_%d") + '.csv'
    filenames = ['./res/'+file_yesterday, './res/'+file_name_date]
    with open('./res/concatefile.csv', 'w') as outfile:
        for fname in filenames:
            with open(fname) as infile:
                for line in infile:
                    outfile.write(line)
    return send_from_directory('./res', 'concatefile.csv')


@app.route('/api/last', methods=['GET'])
def get_last() -> str:
    print("/api/last")
    res = monitoring_bvf.last_observation
    print("returning " + res)
    return res


@app.route('/api/time')
def get_time():
    time = datetime.now()
    return "RPI3 date and time: " + str(time)


app.run(host='0.0.0.0', port=8090)
