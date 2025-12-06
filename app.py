from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import subprocess
import json

app = FastAPI(title="Blackbird OSINT API", version="1.0.0")


class SearchRequest(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None


@app.get("/")
def read_root():
    return {
        "status": "ok",
        "message": "Blackbird OSINT API is running.",
        "endpoints": ["/search"],
    }


@app.post("/search")
def search(request: SearchRequest):
    if not request.username and not request.email:
        raise HTTPException(
            status_code=400,
            detail="You must provide at least 'username' or 'email'.",
        )

    cmd = ["python", "blackbird.py"]

    if request.username:
        cmd += ["--username", request.username]
    if request.email:
        cmd += ["--email", request.email]

    cmd.append("--json")

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to run Blackbird: {e}")

    if result.returncode != 0:
        err_tail = result.stderr.strip()[-500:]
        raise HTTPException(
            status_code=500,
            detail=f"Blackbird returned an error. Tail: {err_tail}",
        )

    stdout = result.stdout.strip()
    first_brace = stdout.find("{")
    if first_brace > 0:
        stdout = stdout[first_brace:]

    try:
        data = json.loads(stdout)
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=500,
            detail="Could not parse Blackbird JSON output.",
        )

    return {
        "query": request.dict(),
        "results": data,
    }
