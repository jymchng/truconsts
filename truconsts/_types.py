from typing import Type, Tuple
from types import MethodType
from ._base_immu import BaseImmutable


def patch_cls(cls):
    def __cls_getitem__(cls, index):
        if isinstance(index, (Type, Tuple)) or index == Lazy or index == Async:
            res = (cls, *index) if isinstance(index, tuple) else (cls, index)
            if ((Lazy in res) and (Async in res)):
                raise Exception(f"Subscripts cannot contain both `Lazy` and `Async`")
            return res
        raise Exception(f"`{index}` is not a type or tuple(type) or `Lazy`")
    def __init__(self, *args, **kwargs):
        raise Exception(f"`{self.__name__}` cannot be instantiated")
    # def __init_subclass__(self, *args, **kwargs):
    #     raise Exception(f"`{self.__name__}` cannot be subclassed")
    cls.__init__ = MethodType(__init__, cls)
    # cls.__init_subclass__ = MethodType(__init_subclass__, cls)
    cls.__class_getitem__ = MethodType(__cls_getitem__, cls)
    return cls


# class MetaForImmutable(type):
#     ...


@patch_cls
class Immutable(BaseImmutable):
    ...


@patch_cls
class Mutable:
    ...


@patch_cls
class Lazy:
    ...
    
    
@patch_cls
class Async:
    ...

