#cython: language_level=3
from cpython cimport PyTypeObject

cdef class MetaForImmutables(type):
    cdef readonly set _attrs
    cdef readonly set _lazy
    cdef readonly set _async
    cdef bint _init
    cdef PyTypeObject * pytype_ptr
    cdef readonly tuple _const_as
    cdef readonly object __init_subclass__