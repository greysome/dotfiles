from collections import namedtuple
from datetime import datetime
from itertools import groupby
from time import sleep
import re
import socket
import subprocess
import psutil

WIDTH = ''
HEIGHT = 35
X = 0
Y = 0
GEOMETRY = f'{WIDTH}x{HEIGHT}+{X}+{Y}'
FONT = 'Iosevka-12'
BATTERY_DIR = '/sys/class/power_supply/BAT0'
DELAY = 0.1

def format_fg(color):
    return '%{F' + color + '}'

def format_bg(color):
    return '%{B' + color + '}'

FG_BODY_NORMAL = format_fg('#cccccc')
BG_BODY_NORMAL = format_bg('#444444')
FG_HEADER_NORMAL = format_fg('#ffffff')
BG_HEADER_NORMAL = format_bg('#444444')
FG_LOW_BATTERY = format_fg('#ffffff')
BG_LOW_BATTERY = format_bg('#ee0000')
BG_BAR = '#000000'
CENTER = '%{c}'
LEFT = '%{l}'
RIGHT = '%{r}'
SEPARATOR = ' '
cycle_num = 0

def get_stdout(command):
    pipe = subprocess.Popen(command.split(' '),
                            stdout=subprocess.PIPE,
                            stderr=subprocess.DEVNULL)
    return str(pipe.stdout.read())

def status_datetime():
    return datetime.now().strftime('%d/%m %H:%M')

def status_volume():
    volume_raw = get_stdout('amixer -c 1 sget Master')
    # -2 because there is a trailing newline
    last_line = volume_raw.split('\\n')[-2]
    # Get the 5th word
    volume = re.split('\W+', last_line)[4]
    return volume

def status_battery_level():
    with open(BATTERY_DIR + '/capacity') as f:
        # The file has 1 line
        return int(f.readlines()[0])

def status_battery_status():
    with open(BATTERY_DIR + '/status') as f:
        # Get the first character
        return f.readlines()[0][0]

def status_connected():
    try:
        socket.create_connection(('www.google.com', 80))
    except OSError:
        return False
    else:
        return True

def status_network():
    interfaces = get_stdout('iwconfig')
    return interfaces.split('\\n')[0].split('ESSID:')[1].strip()[1:-1]

def status_cpu():
    return str(psutil.cpu_percent(interval=None))

def status_ram():
    return str(psutil.virtual_memory().percent)

def status_disk():
    return str(psutil.disk_usage('/').percent)

def status_workspaces():
    num_workspaces = int(get_stdout("xdotool get_num_desktops")[2:-3])
    cur_workspace = int(get_stdout("xdotool get_desktop")[2:-3])

    workspaces_str = ''
    for i in range(num_workspaces):
        workspaces_str += '{}{}'.format(format_fg('#ffffff') if i == cur_workspace
                                        else format_fg('#999999'), i+1)
        if i < num_workspaces-1:
            workspaces_str += '  '
    workspaces_str += FG_BODY_NORMAL
            
    return workspaces_str

Section = namedtuple('Section', ('alignment', 'fg_header', 'bg_header', 'header',
                                 'fg_body', 'bg_body', 'body'))
def sections_to_string(sections, separator):
    display_string = ''

    # Separate into left, center and right groups
    groups = groupby(sections, lambda s: s.alignment)
    for k, sections in groups:
        group_string = format_bg(BG_BAR)
        sections = [i for i in sections]

        for idx, s in enumerate(sections):
            group_string += (s.alignment if idx == 0 else '') + \
                            s.fg_header + s.bg_header + \
                            (' ' if s.header else '') + \
                            s.header + ' ' + \
                            s.fg_body + s.bg_body + s.body
            if idx < len(sections) - 1:
                group_string += separator
            display_string += group_string

    return display_string

def write_bar(bar, display_string):
    bar.stdin.write((display_string + '\n').encode('utf-8'))
    try:
        bar.stdin.flush()
    except BrokenPipeError:
        # Process killed
        exit()

def run():
    global cycle_num
    status = subprocess.Popen(['lemonbar', '-d', '-p', '-g', GEOMETRY,
                               '-o', '1', '-f', FONT,
                               '-B', BG_BAR],
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE)
    while True:
        datetime = status_datetime()
        volume = status_volume()
        workspaces = status_workspaces()
        cpu = status_cpu()
        ram = status_ram()
        disk = status_disk()

        # run expensive network operations only once in a while
        if cycle_num % 40 == 0:
            battery_level = status_battery_level()
            battery_status = status_battery_status()
            connected = status_connected()
            if connected:
                network = status_network()

        low_battery = battery_level < 15 and battery_status == 'D'
        fg_header = (FG_LOW_BATTERY if low_battery else FG_HEADER_NORMAL)
        bg_header = (BG_LOW_BATTERY if low_battery else BG_HEADER_NORMAL)
        fg_body = (FG_LOW_BATTERY if low_battery else FG_BODY_NORMAL)
        bg_body = (BG_LOW_BATTERY if low_battery else BG_BODY_NORMAL)

        sections_status = [
            Section(LEFT, fg_header, bg_header,
                    '', fg_body, bg_body, workspaces),
            Section(CENTER, fg_header, bg_header,
                    str(datetime), fg_body, bg_body, ''),
            Section(RIGHT, fg_header, bg_header,
                    'VOL', fg_body, bg_body, str(volume)),
            Section(RIGHT, fg_header, bg_header,
                    'BAT', fg_body, bg_body, '{} {}'.format(battery_level,
                                                            battery_status)),
            Section(RIGHT, fg_header, bg_header,
                    'WIFI', fg_body, bg_body, (network if connected else '-'))
        ]
        display_string = sections_to_string(sections_status, SEPARATOR)
        write_bar(status, display_string)

        sleep(DELAY)
        cycle_num += 1

if __name__ == '__main__':
    run()
