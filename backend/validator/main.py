import argparse
from decision import decide
import weather.algo as weather

parser = argparse.ArgumentParser(description='Decide if an event occurred based on weather data provided as input')
parser.add_argument('--file', '-f', required=True, help='the file with the weather data')
parser.add_argument('--latitude', '-lat', required=True, type=float, help='the latitude of the point of interest (search within 5km radius)')
parser.add_argument('--longitude', '-lon', required=True, type=float, help='the longitude of the point of interest (search within 5km radius)')
parser.add_argument('--type', '-t', required=True, 
                    choices=['rain', 'heat', 'extreme'], help='what type of function to apply to the data')

args = parser.parse_args()

path, lat, lon = args.file, args.latitude, args.longitude

algo = weather.has_rain
if args.type == 'rain':
    algo = weather.has_rain
elif args.type == 'heat':
    algo = weather.has_high_temp
else:
    algo = weather.has_extreme_conditions

decision = decide(path, algo, lat, lon)
print(decision)


