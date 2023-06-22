from ._types import Mutable, Immutable, Lazy, Async
from ._base import BaseConstants

__VERSION__ = version = Version = __version__ = "0.0.6"

__all__ = [
    'Immutable',
    'Mutable',
    'Lazy',
    'Async',
]

def does_it_work():
    print("Yes, it does!")
