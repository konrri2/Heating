from typing import Dict


class Room:
    def __init__(self, id_on_page, name, number_name, thermostat_id, temp_at_6_cooling, temp_at_22_cooling, temp_at_22_heating, temp_at_6_heating):
        self.id_on_page = id_on_page
        self.name = name
        self.number_name = number_name  # numbers on webpage are 0-7 but button names are room1-room8
        self.thermostat_id = thermostat_id
        self.temp_at_6_cooling = temp_at_6_cooling
        self.temp_at_22_cooling = temp_at_22_cooling
        self.temp_at_22_heating = temp_at_22_heating
        self.temp_at_6_heating = temp_at_6_heating

    current_temp = "-100.0"
    set_temp = "-100.0"
    is_on = False
    mode = ""

    def serialize2array(self):
        arr = [self.number_name, self.current_temp, self.set_temp, self.is_on, self.mode, ""]
        return arr

    def build_csv_header(self):
        arr = [self.name, "current_temp", "set_temp", "is_on", "mode", self.theromstat_id]
        return arr

    # a factor in linear function (where time unit are minutes)
    def calc_heating_a_factor(self):
        delta = self.temp_at_6_heating - self.temp_at_22_heating
        return delta/(8.0*60.0)

    # a factor in linear function while cooling
    def calc_cooling_a_factor(self):
        delta = self.temp_at_22_cooling - self.temp_at_6_cooling
        return delta/(16.0*60.0)


rooms_arr = []

