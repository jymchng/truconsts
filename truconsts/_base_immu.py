try:
    from cy_src.immumeta import MetaForImmutables
except ImportError:
    from truconsts.immumeta import MetaForImmutables

class BaseImmutable(metaclass=MetaForImmutables):
    ...