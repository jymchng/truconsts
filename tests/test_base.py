from truconsts._types import Cache, Mutable, Immutable, Yield
import pytest

# def test_unable_to_inherit():
#     with pytest.raises(Exception):
#         class ChildCache(Cache):
#             pass
        
def test_cannot_subscript_lazy_async_together():
    with pytest.raises(Exception):
        Yield[Cache]
        
    with pytest.raises(Exception):
        Cache[Yield]
        
    assert Cache[Immutable] == (Immutable, Cache) or Cache[Immutable] == (Cache, Immutable)
    assert Immutable[Cache] == (Immutable, Cache) or Immutable[Cache] == (Cache, Immutable)
    
    assert Yield[Immutable] == (Immutable, Yield) or Yield[Immutable] == (Yield, Immutable)
    assert Immutable[Yield] == (Immutable, Yield) or Immutable[Yield] == (Yield, Immutable)
    
def test_cannot_be_instantiated():
    with pytest.raises(Exception):
        Yield()
        
    with pytest.raises(Exception):
        Cache()
        
    with pytest.raises(Exception):
        Immutable()