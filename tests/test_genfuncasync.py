import pytest
from truconsts.annotations import Immutable, Mutable, Cache, Yield
from truconsts.constants import BaseConstants
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


async def coro_wt():
    while True:
        return next(gen())


class NotCache(BaseConstants):
    async_gen: Yield = async_gen
    gen: Yield = gen
    coro: Yield = coro
    func: Yield = func


class NotCacheButActualTypes(BaseConstants):
    async_gen: Yield = async_gen()
    gen: Yield = gen()
    coro_wt: Yield = coro_wt()
    func: Yield = func


def test_NCBAT_async_gen():
    for i in range(10):
        assert NotCacheButActualTypes.async_gen == i


def test_NCBAT_gen():
    for i in range(10):
        assert NotCacheButActualTypes.gen == i


def test_NCBAT_coro_wt():
    assert NotCacheButActualTypes.coro_wt == 0

    with pytest.raises(RuntimeError):
        NotCacheButActualTypes.coro_wt


def test_NCBAT_func():
    assert NotCacheButActualTypes.func == 'func'

# don't use pytest.mark.asyncio to test


@pytest.mark.skip
async def test_not_lazy_async_gen():
    gen_ = gen()
    async for i in NotCache.async_gen:
        # print(i, NotCache.async_gen)
        assert i == next(gen_)


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
    async_gen: Cache = async_gen
    gen: Cache = gen
    coro: Cache = coro
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
