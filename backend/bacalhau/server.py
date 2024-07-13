import requests
from fastapi import FastAPI
from api import create_job, get_job_results
from datetime import datetime, time
from enum import Enum

class ModelType(str, Enum):
    rain = "rain"
    heat = "heatwave"
    extreme = "extreme weather conditions"

def to_seconds(t):
    return round(t / 1000) 

cache = {}

app = FastAPI()

@app.put("/insurance/{insurance_id}")
def trigger(insurance_id: int, type: ModelType, lat: float, lon: float, after: int, before: int):
    response = requests.get('https://basin.tableland.xyz/vaults/wxm.weather_data_dev/events', 
                            params={'limit': 50, 'after': to_seconds(after), 'before': to_seconds(before)}).json()
    cids = [r['cid'] for r in response]
    job_id = create_job(f'test-job-{datetime.now()}', insurance_id, type, f'{insurance_id}-{type}', cids)
    cache[insurance_id] = job_id
    return {"job_id": job_id}

@app.get("/insurance/{insurance_id}")
def read_item(insurance_id: int, type: ModelType, lat: float, lon: float, after: int, before: int):
    if insurance_id not in cache:
        return {"message": "not found"}
    job_id = cache[insurance_id]
    result = get_job_results(job_id)
    return {"job_id": job_id, "insurance_id": insurance_id, "result": result}


