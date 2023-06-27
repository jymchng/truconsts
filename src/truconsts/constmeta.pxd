#cython: language_level=3
cdef class MetaForConstants(type):
    cdef bint _init
    cdef dict _map