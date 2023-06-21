from typing import Type, Tuple
from types import MethodType


def patch_cls_getitem(cls):
    def __cls_getitem__(cls, index):
        if isinstance(index, (Type, Tuple)) or index == Lazy or index == Async:
            return (cls, *index) if isinstance(index, tuple) else (cls, index)
        raise Exception(f"`{index}` is not a type or tuple(type) or `Lazy`")
    cls.__class_getitem__ = MethodType(__cls_getitem__, cls)
    return cls


class MetaForImmutable(type):
    ...


class BaseImmutable(metaclass=MetaForImmutable):
    ...


@patch_cls_getitem
class Immutable(BaseImmutable):
    ...


@patch_cls_getitem
class Mutable:
    ...


@patch_cls_getitem
class Lazy:
    ...
    
    
@patch_cls_getitem
class Async:
    ...

