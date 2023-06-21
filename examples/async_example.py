from truconsts import BaseConstants, Immutable, Lazy, Async
import httpx
from httpx import Response
from pydantic import BaseModel
from typing import List, Dict, Coroutine
import orjson
from functools import partial
import time


class SuiGetRequest(BaseModel):
    jsonrpc: str = "2.0"
    method: str
    params: List[str] = []
    id: int = 1


class MethodNames(BaseConstants):
    sui_getLatestCheckpointSequenceNumber: Immutable = 'sui_getLatestCheckpointSequenceNumber'


async def network_getter(url: str, headers: Dict[str, str], method_name: MethodNames, params: List[str]) -> Coroutine:
    async with httpx.AsyncClient(base_url=url, headers=headers) as client:
        data = orjson.dumps(SuiGetRequest(method=method_name).dict())
        response: Response = await client.post(url='/', data=data)
    return response.json()['result']


class AsyncConstants(BaseConstants):
    # `Immutable` and it is a `str`
    NETWORK: Immutable[str] = "mainnet"
    # Un-annotated means `Mutable`, can annotate with `Mutable` too, e.g.
    # `Mutable[Dict[str, str]]`
    HEADERS = {'Content-Type': 'application/json'}
    SUI_FULL_NODE_URL: Immutable[str] = "https://fullnode.{}.sui.io:443"

    # This is the interesting one, this implies that the `LATEST_CHECKPOINT_SEQUENCE_NUMBER`
    # should be `awaited` every time the attribute `LATEST_CHECKPOINT_SEQUENCE_NUMBER`
    # is accessed, i.e. when 'calling'
    # `AsyncConstants.LATEST_CHECKPOINT_SEQUENCE_NUMBER`
    LATEST_CHECKPOINT_SEQUENCE_NUMBER: Async[str] = partial(
        network_getter,
        SUI_FULL_NODE_URL.format(NETWORK),
        HEADERS,
        MethodNames.sui_getLatestCheckpointSequenceNumber,
        list())


if __name__ == '__main__':

    for _ in range(10):
        prev = AsyncConstants.LATEST_CHECKPOINT_SEQUENCE_NUMBER
        time.sleep(0.5)
        now = AsyncConstants.LATEST_CHECKPOINT_SEQUENCE_NUMBER
        print(f'prev={prev}; now={now}')
        assert prev != now, f'prev={prev}; now={now}'

        # >>> \truconsts>python -m examples.async_example
        # ... prev=5715141; now=5715142
        # ... prev=5715143; now=5715144
        # ... prev=5715145; now=5715147
        # ... prev=5715147; now=5715149
        # ... prev=5715150; now=5715151
        # ... prev=5715152; now=5715153
        # ... prev=5715154; now=5715155
        # ... prev=5715156; now=5715158
        # ... prev=5715158; now=5715160
        # ... prev=5715161; now=5715162
