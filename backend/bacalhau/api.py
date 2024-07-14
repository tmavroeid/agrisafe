import requests
import pprint
import json
import os
from string import Template

# os.environ['BACALHAU_API_HOST'] = "bootstrap.production.bacalhau.org"
os.environ['BACALHAU_API_HOST'] = "0.0.0.0"
os.environ['REQUESTER_API_PORT'] = "1234" # Port 1234 by default

REQUESTER_HOST = os.environ["BACALHAU_API_HOST"]
REQUESTER_API_PORT = os.environ['REQUESTER_API_PORT']
REQUESTER_BASE_URL = f"http://{REQUESTER_HOST}:{REQUESTER_API_PORT}"

def create_job(name, insurance_id, insurance_type, task_id, cids):
    job = Template('''
    {
      "Job": {
        "Name": "${name}",
        "Type": "batch",
        "Count": 1,
        "Labels": {
          "insurance": "${insurance_id}",
          "type": "${insurance_type}"
        },
        "Tasks": [
          {
            "Name": "${task_id}",
            "Engine": {
              "Type": "docker",
              "Params": {
                "Image": "ubuntu:latest",
                "Entrypoint": [
                  "ls",
                  "/data"
                ]
              }
            },
            "Publisher": {
              "Type": "noop"
            },
            "InputSources": [
              {
                "Target": "/data/data.parquet",
                "Source": {
                  "Type": "localDirectory",
                  "Params": {
                    "SourcePath": "/home/peris/hack/validator/data/1717337952982163-data.parquet"
                  }
                }
              }
            ]
          }
        ]
      }
    }
    ''').substitute(
        name=name, insurance_id=insurance_id, insurance_type=insurance_type, 
        task_id=task_id, cid=cids[0])
    print(job)

    createJobResp = requests.put(f"{REQUESTER_BASE_URL}/api/v1/orchestrator/jobs", json=json.loads(job))
    createJobRespData = None


    if createJobResp.status_code == 200:
        createJobRespData = createJobResp.json()
        pprint.pprint(createJobRespData)
        return createJobRespData['JobID']
    else:
        print(f"Failed to retrieve nodes. HTTP Status code: {createJobResp.status_code}")
        print(f"Response: {createJobResp.text}")
        return None


def get_job_results(job_id):
    getJobExecResp = requests.get(f"{REQUESTER_BASE_URL}/api/v1/orchestrator/jobs/{job_id}/executions")
    getJobExecRespData = None


    if getJobExecResp.status_code == 200:
        # Pretty print the JSON data
        pprint.pprint(getJobExecResp.json())
        getJobExecRespData = getJobExecResp.json()
        
        for item in getJobExecRespData.get("Items", []):
          print(f"Execution ID: {item['ID']}")


          if item["RunOutput"] != None:
            result = item["RunOutput"]["Stdout"]
            print("Stdout:")
            print(result)
            print("-" * 20)  # Separator for readability
            return result
          else:
            print(f"No data returned at this point for execution {item['ID']}")
            return None


    else:
        print(f"Failed to retrieve nodes. HTTP Status code: {createJobResp.status_code}")
        print(f"Response: {createJobResp.text}")
        return None


