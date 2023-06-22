try:
    from .immumeta import MetaForImmutables
except ImportError:
    from cy_src.immumeta import MetaForImmutables

class BaseImmutable(metaclass=MetaForImmutables):
    ...