import argparse
import requests
from datetime import datetime, time
from api import create_job, get_job_results

def to_seconds(t):
    return round(t.timestamp()) 

parser = argparse.ArgumentParser(description='Decide if an event occurred based on weather data provided as input')
parser.add_argument('--after', '-a', required=True, help='the lower limit of the date range (YYYY-MM-DD)')
parser.add_argument('--before', '-b', required=True, help='the upper limit of the date range (YYYY-MM-DD)')
parser.add_argument('--latitude', '-lat', required=True, type=float, help='the latitude of the point of interest (search within 5km radius)')
parser.add_argument('--longitude', '-lon', required=True, type=float, help='the longitude of the point of interest (search within 5km radius)')
parser.add_argument('--type', '-t', required=True, 
                    choices=['rain', 'heat', 'extreme'], help='what type of function to apply to the data')

args = parser.parse_args()

start_of_day = datetime.strptime(args.after, '%Y-%m-%d')
end = datetime.strptime(args.before, '%Y-%m-%d')
end_of_day = datetime.combine(end, time.max)
after, before = to_seconds(start_of_day), to_seconds(end_of_day)
 
response = requests.get('https://basin.tableland.xyz/vaults/wxm.weather_data_dev/events', params={'limit': 50, 'after': after, 'before': before}).json()
cids = [r['cid'] for r in response]
print(cids)

# get_job_results('j-5def0df1-6ad6-4fbe-888e-58f818ec442d')
create_job('tester', 'rain', 'test-task-id', cids)

