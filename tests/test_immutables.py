from truconsts._types import Yield, Lazy, Mutable, Immutable
import pytest

class Immutables(Immutable):
    FIRST = 'FIRST'
    SECOND = 'SECOND'
    
    
# def test_immutables_are_immutable():
    
#     for _ in range(200):
#         assert Immutables.FIRST == 'FIRST'
        
#         with pytest.raises(AttributeError):
#             Immutables.FIRST = 'NOT_FIRST'

#     for _ in range(200):
#         assert Immutables.SECOND == 'SECOND'
        
#         with pytest.raises(AttributeError):
#             Immutables.SECOND = 'NOT_SECOND'
            
# def test_immutables_cannot_have_const_as_nonempty():
#     with pytest.raises(ValueError):
#         class Immutables(Immutable, const_as=(Async,)):
#             FIRST = 'FIRST'
#             SECOND = 'SECOND'