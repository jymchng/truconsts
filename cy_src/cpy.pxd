#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii
# Py_TPFLAGS_BASETYPE
cdef extern from "Python.h":
    # https://docs.python.org/3/c-api/typeobj.html#c.PyTypeObject
    ctypedef int (*setattrofunc)(type, object, object) except -1
    ctypedef object (*getattrofunc)(type, object)
    int PyCoro_CheckExact(object o)
    int PyCallable_Check(object o)

    ctypedef struct PyTypeObject_PythonType "PyTypeObject":
        setattrofunc tp_setattro
        getattrofunc tp_getattro

    cdef PyTypeObject_PythonType PyType_Type