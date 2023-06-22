from cy_src.immumeta import MetaForImmutables
from truconsts._types import Async, Lazy, Mutable
import pytest

class BaseImmutables(metaclass=MetaForImmutables):
    ...
    
class Immutable(BaseImmutables):
    ...
    
class Immutables(Immutable):
    FIRST = 'FIRST'
    SECOND = 'SECOND'
    
    
def test_immutables_are_immutable():
    
    for _ in range(200):
        assert Immutables.FIRST == 'FIRST'
        
        with pytest.raises(AttributeError):
            Immutables.FIRST = 'NOT_FIRST'

    for _ in range(200):
        assert Immutables.SECOND == 'SECOND'
        
        with pytest.raises(AttributeError):
            Immutables.SECOND = 'NOT_SECOND'
            
def test_immutables_cannot_have_const_as_nonempty():
    with pytest.raises(ValueError):
        class Immutables(Immutable, const_as=(Async,)):
            FIRST = 'FIRST'
            SECOND = 'SECOND'