#cython: language_level=3
from cpython cimport PyTypeObject

cdef class MetaForConstants(type):
    cdef readonly set _immutable
    cdef readonly set _attrs
    cdef readonly set _cache
    cdef readonly set _yield
    cdef readonly bint _init
    cdef PyTypeObject * pytype_ptr