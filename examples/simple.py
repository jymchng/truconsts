from datetime import datetime
import time
from truconsts.constants import BaseConstants
from truconsts.annotations import Yield, Immutable, Mutable, Cache

def get_constant(what='Hey'):
    """A function to illustrate the caching ability of subclasses of `BaseConstants`"""
    time.sleep(5)
    return what


# simple API, just subclass `BaseConstants`
class Constants(BaseConstants):
    # `NUM` is an immutable `int`, i.e. Constants.NUM will always be 123
    NUM: Immutable[int] = 123
    # No `Immutable` annotation implies Constants.STR is mutable
    STR: str = "Hello"
    # Constants.IMMU_FUNC will call `get_constant` function; the returned value is cached
    # and it is immutable
    IMMU_FUNC: Cache[Immutable] = get_constant
    # Order/Subscripting of annotation does not matter
    MUT_FUNC: Immutable[Cache] = get_constant
    # Only `Cache` annotation without `Immutable` means it is mutable even after
    # the returned value is cached after being called for the first time
    JUST_CACHE: Cache[str] = get_constant
    # No annotation means it is neither `Cache` nor `Immutable`
    NO_ANNO = "NO_ANNO"
##############################################################################
assert Constants.NUM == 123
try:
    Constants.NUM = 321
except AttributeError as err:
    print(err)
# ... `Constants.NUM` cannot be mutated
##############################################################################
start = datetime.now()
assert Constants.IMMU_FUNC == 'Hey'
end = datetime.now()
print(f"First time class attribute is accessed took: {end-start} seconds.")

try: # immutable
    Constants.IMMU_FUNC = 321
except AttributeError as err:
    print(err)

# test subsequent class attribute access is way faster because it is cached
start = datetime.now()
for _ in range(1_000_000):
    g = Constants.IMMU_FUNC
end = datetime.now()
print(f"Subsequent 1_000_000 accesses took: {end-start} seconds.")

# ... First time class attribute is accessed took: 0:00:05.002227 seconds.
# ... `Constants.IMMU_FUNC` cannot be mutated
# ... Subsequent 10000 accesses took: 0:00:00.004978 seconds.
##############################################################################
start = datetime.now()
assert Constants.JUST_CACHE == 'Hey'
end = datetime.now()
print(f"First time class attribute is accessed took: {end-start} seconds.")

# test subsequent class attribute access is way faster because it is cached
start = datetime.now()
for _ in range(1_000_000):
    g = Constants.JUST_CACHE
end = datetime.now()
print(f"Subsequent 1_000_000 accesses took: {end-start} seconds.")

# cached but mutable
import random
start = datetime.now()
for _ in range(1_000_000):
    rand_int = random.randint(1, 10000)
    Constants.JUST_CACHE = rand_int
    assert Constants.JUST_CACHE == rand_int
end = datetime.now()
print(f"Subsequent 1_000_000 accesses took: {end-start} seconds.")
# ... First time class attribute is accessed took: 0:00:05.013457 seconds.
# ... Subsequent 1_000_000 accesses took: 0:00:00.236997 seconds.
# ... Subsequent 1_000_000 accesses took: 0:00:01.953030 seconds.
##############################################################################