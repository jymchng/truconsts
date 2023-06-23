import pytest
from cy_src.constmeta import MetaForConstants
from truconsts._types import Immutable, Mutable, Lazy, Yield
from truconsts._base_const import BaseConstants
from types import AsyncGeneratorType

async def async_gen():
    for i in range(10):
        yield i
        
def gen():
    for i in range(10):
        yield i
        
async def coro():
    return 'coro'

def func():
    return 'func'


class NotLazy(BaseConstants):
    async_gen: Yield = async_gen()
    gen: Yield = gen()
    coro: Yield = coro()
    func: Yield = func
    
def test_not_lazy_async_gen():
    for i in range(10):
        print(i, NotLazy.async_gen)
    raise
        
def test_not_lazy_gen():
    for i in range(10):
        assert NotLazy.gen == i
        
def test_not_lazy_coro():
    assert NotLazy.coro == 'coro'
    
def test_not_lazy_func():
    assert NotLazy.func == 'func'
    
async def async_gen():
    for i in range(10):
        yield i
        
def gen():
    for i in range(10):
        yield i
        
async def coro():
    return 'coro'

def func():
    return 'func'


class VeryLazy(BaseConstants):
    async_gen: Lazy = async_gen()
    gen: Lazy = gen()
    coro: Lazy = coro()
    func: Lazy = func
    
def test_very_lazy_async_gen():
    for i in range(10):
        print(i, VeryLazy.async_gen)
        assert VeryLazy.async_gen == 0
        
def test_very_lazy_gen():
    for i in range(10):
        assert VeryLazy.gen == 0
        
def test_very_lazy_coro():
    for i in range(10):
        assert VeryLazy.coro == 'coro'
    
def test_very_lazy_func():
    for i in range(10):
        assert VeryLazy.func == 'func'