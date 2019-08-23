#!flask/bin/python
from flask import Flask, jsonify, request, send_from_directory
import os.path
from datetime import datetime
import monitoring_bvf
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
    return send_from_directory('res', 'all.csv')
    # app.send_file('/measurements_format.csv', attachment_filename='measurements_format.csv')
    # return send_from_directory(directory=uploads, filename='measurements_format.csv')


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
