from typing import Any


try:
    from .meta import MetaForConstants
except ImportError:
    from cy_src.meta import MetaForConstants


class BaseConstants(metaclass=MetaForConstants):
    
    def __getattribute__(self, __name: str) -> Any:
        return self.__class__.__getattribute__(self.__class__, __name)
