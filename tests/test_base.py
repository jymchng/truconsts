from truconsts import Lazy, Mutable, Immutable, Async
import pytest

def test_unable_to_inherit():
    with pytest.raises(Exception):
        class ChildLazy(Lazy):
            pass
        
def test_cannot_subscript_lazy_async_together():
    with pytest.raises(Exception):
        Async[Lazy]
        
    with pytest.raises(Exception):
        Lazy[Async]
        
    assert Lazy[Immutable] == (Immutable, Lazy) or Lazy[Immutable] == (Lazy, Immutable)
    assert Immutable[Lazy] == (Immutable, Lazy) or Immutable[Lazy] == (Lazy, Immutable)
    
    assert Async[Immutable] == (Immutable, Async) or Async[Immutable] == (Async, Immutable)
    assert Immutable[Async] == (Immutable, Async) or Immutable[Async] == (Async, Immutable)
    
def test_cannot_be_instantiated():
    with pytest.raises(Exception):
        Async()
        
    with pytest.raises(Exception):
        Lazy()
        
    with pytest.raises(Exception):
        Immutable()