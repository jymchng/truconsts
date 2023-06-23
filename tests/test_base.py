from truconsts._types import Lazy, Mutable, Immutable, Yield
import pytest

# def test_unable_to_inherit():
#     with pytest.raises(Exception):
#         class ChildLazy(Lazy):
#             pass
        
def test_cannot_subscript_lazy_async_together():
    with pytest.raises(Exception):
        Yield[Lazy]
        
    with pytest.raises(Exception):
        Lazy[Yield]
        
    assert Lazy[Immutable] == (Immutable, Lazy) or Lazy[Immutable] == (Lazy, Immutable)
    assert Immutable[Lazy] == (Immutable, Lazy) or Immutable[Lazy] == (Lazy, Immutable)
    
    assert Yield[Immutable] == (Immutable, Yield) or Yield[Immutable] == (Yield, Immutable)
    assert Immutable[Yield] == (Immutable, Yield) or Immutable[Yield] == (Yield, Immutable)
    
def test_cannot_be_instantiated():
    with pytest.raises(Exception):
        Yield()
        
    with pytest.raises(Exception):
        Lazy()
        
    with pytest.raises(Exception):
        Immutable()