import pytest
from cy_src.constmeta import MetaForConstants
from truconsts._types import Immutable, Mutable, Lazy, Async
from truconsts._base_const import BaseConstants

# class BaseConstants(metaclass=MetaForConstants):
#     ...
    
def get_root_dir():
    return 'THIS_IS_A_ROOT_DIR'

async def get_async_root_dir():
    return 'THIS_IS_AN_ASYNC_ROOT_DIR'

# to avoid RuntimeError: cannot reuse already awaited coroutine
async def another_coroutine():
    return 'THIS_IS_AN_ASYNC_ROOT_DIR'

# to avoid RuntimeError: cannot reuse already awaited coroutine
async def yet_another_coroutine():
    return 'THIS_IS_AN_ASYNC_ROOT_DIR'
    
class Constants(BaseConstants):
    ROOT_DIR: Immutable[str] = 'HELLO' # Immutable
    YAY: Immutable = 'YAY' # Immutable
    NEW: str = 'HIHI' # Mutable
    OLD = 'OLD' # Mutable
    GOOD = 'YES' # Mutable
    # Impossible to call in pure python, recursion error
    NEW_ROOT_DIR: Immutable[Lazy[str]] = get_root_dir 
    # Call it once and still can mutate thereafter
    ONLY_LAZY: Lazy[str] = get_root_dir 
    # Call it once and never mutate it, Lazy[Immutable] is same as Immutable[Lazy]
    LAZY_IMMUTABLE_STR: Lazy[Immutable[str]] = get_root_dir
    NUMBER: Immutable[int] = 123456
    
class ConstantsWithoutAnnotations(BaseConstants): # behaves like your regular class
    ROOT_DIR_ = 'HELLO'
    NEW_ = 'HIHI'
    OLD_ = 'OLD'
    
def test_constants_immutable():
    assert Constants.ROOT_DIR == 'HELLO'
    assert Constants.NUMBER == 123456
    
    for _ in range(200):  
        with pytest.raises(AttributeError):
            Constants.ROOT_DIR = 'Bye'
        
    for _ in range(200):
        with pytest.raises(AttributeError):
            Constants.NUMBER = 500

def test_constants_mutable_with_annotation():
    assert Constants.NEW == 'HIHI'
    
    Constants.NEW = 'GG'
    assert Constants.NEW == 'GG'

    Constants.NEW = 'XX'
    assert Constants.NEW == 'XX'
    
def test_constants_mutable_without_annotation(): 
    assert Constants.OLD == 'OLD'
    
    Constants.OLD = 'LOL'
    assert Constants.OLD == 'LOL'
    
    Constants.OLD = 'XX'
    assert Constants.OLD == 'XX'
    
def test_constants_without_annotation__cls_var_mutable_without_annotation():
    assert ConstantsWithoutAnnotations.NEW_ == 'HIHI'

    for i in range(50):
        ConstantsWithoutAnnotations.NEW_ = 'GG'
        assert ConstantsWithoutAnnotations.NEW_ == 'GG'
        
        ConstantsWithoutAnnotations.NEW_ = 'XX'
        assert ConstantsWithoutAnnotations.NEW_ == 'XX'
    
def test_constants_cannot_assign_new_class_variable():
    with pytest.raises(AttributeError):
        Constants.MY_GOOD_HOBBY = 'SOCCER?'
        assert Constants.MY_GOOD_HOBBY == 'SOCCER?'
    
    with pytest.raises(AttributeError):
        Constants.MY_BAD_HOBBY: Immutable = "CODING!"
        assert Constants.MY_BAD_HOBBY == "CODING!"
    
def test_constants_attrs():
    assert Constants._attrs == set(('ONLY_LAZY', 'LAZY_IMMUTABLE_STR', 'GOOD', 'NEW', 'OLD', 'ROOT_DIR', 'NEW_ROOT_DIR', 'YAY', "NUMBER"))
    
def test_constants_lazy():
    assert Constants._lazy == set(('ONLY_LAZY', 'LAZY_IMMUTABLE_STR', 'NEW_ROOT_DIR', ))
    
def test_constants_immutable():
    assert Constants._immutable == set(('YAY', 'LAZY_IMMUTABLE_STR', 'ROOT_DIR', 'NEW_ROOT_DIR', "NUMBER"))
    
def test_consts_wo_anno_attrs():
    
    assert ConstantsWithoutAnnotations._attrs == set(('NEW_', 'OLD_', 'ROOT_DIR_'))
    
def test_consts_wo_anno_immutable():
    assert ConstantsWithoutAnnotations._immutable == set()
    
def test_consts_wo_anno_lazy():
    assert ConstantsWithoutAnnotations._lazy == set()

@pytest.mark.skip
def test_consts_wo_anno_cache():
    assert ConstantsWithoutAnnotations._cache == dict()
    
def test_two_classes_dont_share_same_class_vars():
    assert Constants._attrs != ConstantsWithoutAnnotations._attrs
    assert Constants._immutable != ConstantsWithoutAnnotations._immutable
    assert Constants._lazy != ConstantsWithoutAnnotations._lazy
    # assert Constants._cache != ConstantsWithoutAnnotations._cache # .cache removed
    
def test_cannot_add_to_consts_tp_dict():
    with pytest.raises(TypeError):
        Constants.__dict__['SUB_DIR'] = 'GOOD_SUB_DIR'
        Constants.__dict__.update({'HI': 'BYE'})
    
def test_consts_lazy():
    # _cache removed
    # assert 'LAZY_IMMUTABLE_STR' not in Constants._cache
    for _ in range(200):
        assert Constants.LAZY_IMMUTABLE_STR == 'THIS_IS_A_ROOT_DIR'
        assert Constants.ONLY_LAZY == 'THIS_IS_A_ROOT_DIR'
        assert Constants.NEW_ROOT_DIR == 'THIS_IS_A_ROOT_DIR'
        
        for s in ('LAZY_IMMUTABLE_STR', 'ONLY_LAZY', 'NEW_ROOT_DIR'):
            # once initialized, remove from `_lazy`
            assert (s not in Constants._lazy)
        
        with pytest.raises(AttributeError):    
            Constants.LAZY_IMMUTABLE_STR = 'HOW ARE YOU'
            assert Constants.LAZY_IMMUTABLE_STR == 'HOW ARE YOU'
        
        with pytest.raises(AttributeError):
            Constants.NEW_ROOT_DIR = 'HOW ARE YOU'
            assert Constants.NEW_ROOT_DIR == 'HOW ARE YOU'
            
        assert Constants._lazy == set()
            
    for _ in range(200):
        Constants.ONLY_LAZY = 'HOW ARE YOU'
        assert Constants.ONLY_LAZY == 'HOW ARE YOU'
        
        Constants.ONLY_LAZY = 'YOU ARE LAZY'
        assert Constants.ONLY_LAZY == 'YOU ARE LAZY'
        
def test_constants_can_be_inherited():
    class ChildConstants(Constants):
        ...
        
def test_constants_meta_can_be_inherited():
    with pytest.raises(TypeError):
        class ChildConstantsMeta(MetaForConstants):
            ...
        
class AsyncConstants(BaseConstants):
    ASYNC_STR: Async[str] = get_async_root_dir
    ASYNC_IMMU_STR: Async[Immutable[str]] = another_coroutine
    
def test_async_immutable_sets():
    assert AsyncConstants._async == set(('ASYNC_STR', 'ASYNC_IMMU_STR'))
    assert AsyncConstants._immutable == set(('ASYNC_IMMU_STR', ))
    assert AsyncConstants._lazy == set()
    
def test_async_consts_correct():
    assert AsyncConstants.ASYNC_STR == 'THIS_IS_AN_ASYNC_ROOT_DIR'
    
def test_async_consts_correct_two():
    assert AsyncConstants.ASYNC_IMMU_STR == 'THIS_IS_AN_ASYNC_ROOT_DIR'
    
def test_async_consts_mutability():
    for _ in range(2000):
        with pytest.raises(AttributeError):
            AsyncConstants.ASYNC_IMMU_STR = 'NEW_ASYNC_ROOT_DIR'
            assert AsyncConstants.ASYNC_IMMU_STR == 'NEW_ASYNC_ROOT_DIR'
            
        AsyncConstants.ASYNC_STR = 'NEW_ASYNC_ROOT_DIR'
        assert AsyncConstants.ASYNC_STR == 'NEW_ASYNC_ROOT_DIR'
        
def test_subclass_instance_can_be_mutated_but_not_the_class():
    for i in range(1000):
        inst = Constants()
        inst.LAZY_IMMUTABLE_STR = '555'
        assert inst.LAZY_IMMUTABLE_STR == '555'
        assert Constants.LAZY_IMMUTABLE_STR == 'THIS_IS_A_ROOT_DIR'
        
def test_subclass_instance_has_no_dict_two():
    # refresh the class to avoid RuntimeError: cannot reuse already awaited coroutine
    for i in range(10):
        inst = AsyncConstants()
        inst.ASYNC_IMMU_STR = '555'
        assert inst.ASYNC_IMMU_STR == '555'
        assert AsyncConstants.ASYNC_IMMU_STR == 'THIS_IS_AN_ASYNC_ROOT_DIR'