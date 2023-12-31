# Usage Examples

## Immutability of Class Variables

```python
from pathlib import Path
from random import randint
from truconsts.constants import BaseConstants
from truconsts.annotations import Immutable

class DataFilePaths(BaseConstants):
    # these annotated as immutable
    DATA_ROOT: Immutable[Path, str] = Path('data')
    # not annotated at all implies mutable
    TESTING = DATA_ROOT / "testing"
```

We first import `BaseConstants` from `truconsts.constants`.
A new class `DataFilePaths` is defined which inherits from `BaseConstants`. This class defines two class-level constants. `DATA_ROOT` is defined as an immutable `Path` object initialized with the string `'data'`. The `Immutable` annotation indicates that the value of the constant cannot be changed after Python reads the class definition. `TESTING` is defined as a mutable `Path` object obtained by appending the string `'testing'` to the `DATA_ROOT` path.

```python
class GLOBALS(BaseConstants):
    DataFilePaths: Immutable[DataFilePaths] = DataFilePaths
```
In this code, a new class `GLOBALS` is defined that also inherits from `BaseConstants`. This class defines a single class-level constant `DataFilePaths`. The `Immutable` annotation is used to indicate that this constant cannot be reassigned to a new value. The type of this constant is `Immutable[DataFilePaths]`, which means it is an immutable class variable of the `DataFilePaths` class defined earlier.

The value assigned to `DataFilePaths` is the class itself, i.e., `DataFilePaths`. This means that `DataFilePaths` is now available as a constant within the `GLOBALS` class and can be accessed as `GLOBALS.DataFilePaths`.
```python
# not possible to mutate
try:
    DataFilePaths.DATA_ROOT = 'another_data_path'
    assert DataFilePaths.DATA_ROOT == "another_data_path"
    print(DataFilePaths.DATA_ROOT)
except AttributeError as err:
    print(err)
# prints: `DataFilePaths.DATA_ROOT` cannot be mutated

# unannotated means can mutate
try:
    DataFilePaths.TESTING = "another_testing"
    assert DataFilePaths.TESTING == "another_testing"
    print(DataFilePaths.TESTING)
except AttributeError as err:
    print(err)
# prints: another_testing
```
This code tries to modify the values of the `DATA_ROOT` and `TESTING` constants defined in the `DataFilePaths` class and demonstrates the immutability of `DATA_ROOT` and mutability of `TESTING`.

In the first try block, an attempt is made to reassign the value of `DATA_ROOT` to `'another_data_path'`. Since `DATA_ROOT` is defined as immutable with the Immutable annotation, the assignment operation raises an AttributeError with the message "`DataFilePaths.DATA_ROOT` cannot be mutated".

In the second try block, an attempt is made to reassign the value of `TESTING` to `'another_testing'`. Since `TESTING` is not annotated with `Immutable`, it is mutable and the assignment operation succeeds. The new value of `TESTING` is then asserted and printed to the console.

## Yielding From An Asynchronous Generator
Next, we look at an example where an asynchronous generator is assigned to a class variable and is annotated with the `Yield` type hint.

```
from truconsts.constants import BaseConstants
from truconsts.annotations import Yield, Immutable
import httpx
from httpx import Response
from pydantic import BaseModel
from typing import List, Dict
import orjson
```

```python
class SUIPostRequest(BaseModel):
    jsonrpc: str = "2.0"
    method: str
    params: List[str] = []
    id: int = 1
    
class MethodNames(BaseConstants):
    sui_getLatestCheckpointSequenceNumber: Immutable = 'sui_getLatestCheckpointSequenceNumber'
    
print(MethodNames.sui_getLatestCheckpointSequenceNumber)
# prints: 'sui_getLatestCheckpointSequenceNumber'
```

In this code, a new `SUIPostRequest` class is defined which inherits from `pydantic`'s `BaseModel`. This class is used to define the structure of a JSON-RPC request that will be sent to a server.

A new `MethodNames` class is also defined which inherits from `BaseConstants`. This class defines a single class-level constant `sui_getLatestCheckpointSequenceNumber`. The Immutable annotation is used, this constant is defined as immutable. The value of this constant is the string `'sui_getLatestCheckpointSequenceNumber'`.

Finally, the value of `MethodNames.sui_getLatestCheckpointSequenceNumber` is printed to the console, which should output the string `'sui_getLatestCheckpointSequenceNumber'`.

```python
async def network_getter(url: str, headers: Dict[str, str], method_name: MethodNames, params: List[str]):
    # using the asynchronous client of `httpx` to get the result from a json RPC call
    while True:
        async with httpx.AsyncClient(base_url=url, headers=headers) as client:
            data = orjson.dumps(SUIPostRequest(method=method_name).dict())
            response: Response = await client.post(url='/', data=data)
        yield response.json()['result']

class AsyncConstants(BaseConstants):
    NETWORK: Immutable[str] = "mainnet"
    HEADERS = {'Content-Type': 'application/json'}
    SUI_FULL_NODE_URL: Immutable[str] = "https://fullnode.{}.sui.io:443"
    # value of `LATEST_CHECKPOINT_SEQUENCE_NUMBER` is an asynchrous generator
    LATEST_CHECKPOINT_SEQUENCE_NUMBER: Yield[str] =  network_getter(SUI_FULL_NODE_URL.format(NETWORK), HEADERS, MethodNames.sui_getLatestCheckpointSequenceNumber, list())
    
for _ in range(10):
    print(AsyncConstants.LATEST_CHECKPOINT_SEQUENCE_NUMBER, end="; ")
# prints: 6052440; 6052440; 6052441; 6052442; 6052443; 6052444; 6052445; 6052446; 6052447; 6052447; 
```
This code defines a generator that asynchronously retrieves data from a server and a class `AsyncConstants` that stores constants related to the SUI network. It uses the `network_getter()` function to define an asynchronous generator that yields the latest checkpoint sequence number from the SUI network.

A new `AsyncConstants` class is also defined which inherits from BaseConstants. This class defines four class-level constants: `NETWORK` which is an immutable string with the value `"mainnet"`, `HEADERS` which is a dictionary of headers with the value `{'Content-Type': 'application/json'}`, `SUI_FULL_NODE_URL` which is an immutable string with the value `"https://fullnode.{}.sui.io:443"`, where `{}` is replaced by the value of `NETWORK`, and `LATEST_CHECKPOINT_SEQUENCE_NUMBER` which is an asynchronous generator that yields the result of calling the `network_getter()` function with the appropriate arguments. The `Yield` annotation is used to indicate that this constant is an asynchronous generator that yields strings.

Finally, the value of the `LATEST_CHECKPOINT_SEQUENCE_NUMBER` class variable is printed to the console 10 times using a for loop. The output of the asynchronous generator should be a sequence of strings representing the latest checkpoint sequence numbers from the SUI network.