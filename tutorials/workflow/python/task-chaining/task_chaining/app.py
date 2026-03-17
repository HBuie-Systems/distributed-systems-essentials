from contextlib import asynccontextmanager

import dapr.ext.workflow as wf
import uvicorn
from chaining_workflow import chaining_workflow, wf_runtime
from fastapi import FastAPI, status


@asynccontextmanager
async def lifespan(app: FastAPI):
    wf_runtime.start()
    yield
    wf_runtime.shutdown()

app = FastAPI(lifespan=lifespan)

@app.post("/start", status_code=status.HTTP_202_ACCEPTED)
async def start_workflow():
    wf_client = wf.DaprWorkflowClient()
    instance_id = wf_client.schedule_new_workflow(
            workflow=chaining_workflow,
            input="This"
        )
    return {"instance_id": instance_id}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5255)