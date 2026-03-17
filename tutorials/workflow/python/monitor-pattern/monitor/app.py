from contextlib import asynccontextmanager

import dapr.ext.workflow as wf
import uvicorn
from fastapi import FastAPI, status
from monitor_workflow import monitor_workflow, wf_runtime


@asynccontextmanager
async def lifespan(app: FastAPI):
    wf_runtime.start()
    yield
    wf_runtime.shutdown()


app = FastAPI(lifespan=lifespan)


@app.post("/start/{counter}", status_code=status.HTTP_202_ACCEPTED)
async def start_workflow(counter: int):
    wf_client = wf.DaprWorkflowClient()
    instance_id = wf_client.schedule_new_workflow(
        workflow=monitor_workflow, input=counter
    )
    return {"instance_id": instance_id}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5257)
