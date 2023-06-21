try:
    from .meta import MetaForConstants
except ImportError:
    from cy_src.meta import MetaForConstants


class BaseConstants(metaclass=MetaForConstants):
    ...
