from typing import Any


try:
    from .constmeta import MetaForConstants
except ImportError:
    from cy_src.constmeta import MetaForConstants


class BaseConstants(metaclass=MetaForConstants):
    ...
