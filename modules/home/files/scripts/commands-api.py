#!/usr/bin/env -S uv run --script
# -*- python -*-
#
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "uvicorn",
#     "fastapi",
#     "pydantic"
# ]
# ///

import os
import shlex
import subprocess
import sys
from pathlib import Path

import tomllib
import uvicorn
from fastapi import Depends, FastAPI, HTTPException, Security, status
from fastapi.security import APIKeyQuery
from pydantic import BaseModel, ValidationError

xdg_config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))

CONFIG_PATH = xdg_config_home / "commands-api/config.toml"


class Settings(BaseModel):
    key: str


class Action(BaseModel):
    command: str


class Config(BaseModel):
    settings: Settings
    actions: dict[str, Action]


def load_data(path: Path = CONFIG_PATH) -> Config:
    try:
        with path.open("rb") as f:
            data = tomllib.load(f)

        return Config.model_validate(data)

    except FileNotFoundError as e:
        print(e)
        sys.exit(1)

    except tomllib.TOMLDecodeError as e:
        print(f"Invalid TOML: {e}")
        sys.exit(1)

    except ValidationError as e:
        print(f"Invalid config structure: {e}")
        sys.exit(1)


data = load_data()

api_key_query = APIKeyQuery(name="api_key")


async def verify_api_key(api_key: str = Security(api_key_query)):
    if api_key != data.settings.key:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Invalid API key"
        )
    return api_key


app = FastAPI(dependencies=[Depends(verify_api_key)])


@app.get("/run/{action}")
def run_action(action: str):
    if action not in data.actions:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=f"action {action} not found"
        )

    command: str = data.actions[action].command
    subprocess.run(shlex.split(command))

    return {"action": f"ran {action} successfully"}


@app.get("/reload")
def reload_actions():
    global data
    data = load_data()

    return {"reload": "reloaded actions successfully"}


@app.get("/actions")
def get_actions():
    return data.actions


if __name__ == "__main__":
    uvicorn.run("commands-api:app", port=8080, host="0.0.0.0", reload=True)
