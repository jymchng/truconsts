import pytest
from cy_src.constmeta import MetaForConstants
from truconsts._types import Immutable, Mutable, Cache, Yield
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


class NotCache(BaseConstants):
    async_gen: Yield = async_gen()
    gen: Yield = gen()
    coro: Yield = coro()
    func: Yield = func
    
def test_not_lazy_async_gen():
    for i in range(10):
        assert i == NotCache.async_gen
        
def test_not_lazy_gen():
    for i in range(10):
        assert NotCache.gen == i
        
def test_not_lazy_coro():
    assert NotCache.coro == 'coro'
    
def test_not_lazy_func():
    assert NotCache.func == 'func'
    
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


class VeryCache(BaseConstants):
    async_gen: Cache = async_gen()
    gen: Cache = gen()
    coro: Cache = coro()
    func: Cache = func
    
def test_very_lazy_async_gen():
    for i in range(10):
        print(i, VeryCache.async_gen)
        assert VeryCache.async_gen == 0
        
def test_very_lazy_gen():
    for i in range(10):
        print(i, VeryCache.gen)
        assert VeryCache.gen == 0
        
def test_very_lazy_coro():
    for i in range(10):
        print(i, VeryCache.coro)
        assert VeryCache.coro == 'coro'
    
def test_very_lazy_func():
    for i in range(10):
        assert VeryCache.func == 'func'