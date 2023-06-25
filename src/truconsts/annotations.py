from typing import Type, Tuple
from types import MethodType


class InvalidClassSubscripts(BaseException):
    ...


class InstantiationNotAllowed(BaseException):
    ...


def patch_cls(cls):
    def __cls_getitem__(cls, index):
        if isinstance(index, (Type, Tuple)
                      ) or index == Cache or index == Yield:
            res = (cls, *index) if isinstance(index, tuple) else (cls, index)
            if ((Cache in res) and (Yield in res)):
                raise InvalidClassSubscripts(
                    f"Class Subscripts cannot contain both `Cache` and `Yield`")
            return res
        raise InvalidClassSubscripts(
            f"`{index}` is not a type or tuple(type) or `Cache` or `Yield` or a class-subscripted combination of `Cache` and `Yield`")

    def __init__(self, *args, **kwargs):
        raise InstantiationNotAllowed(
            f"`{self.__name__}` cannot be instantiated")
    cls.__init__ = MethodType(__init__, cls)
    cls.__class_getitem__ = MethodType(__cls_getitem__, cls)
    return cls


class MetaForImmutable(type):
    ...


class BaseImmutable(metaclass=MetaForImmutable):
    ...


@patch_cls
class Immutable(BaseImmutable):
    ...


@patch_cls
class Mutable:
    ...


@patch_cls
class Cache:
    ...


@patch_cls
class Yield:
    ...
