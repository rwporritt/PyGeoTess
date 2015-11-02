#cython: embedsignature=True
"""
This module exposes Cython GeoTess functionality from the pxd file into Python.

The class definitions here are Python-visible, and are simply wrappers that 
forward the Python-exposed methods directly to their Cython-exposed c++
counterparts, which have been exposed in the imported pxd file.

This module is also responsible for converting between Python types and c++
types, which sometimes involves tricks.  For simple numerical types, this
conversion done automatically in the calling signature of a "def" method.
Complex c++ class types, however, can't be in a Python-visable "def" method
because Python objects can't be automatically cast to c++ types.  For these
cases, sneaky factory functions that can accept the complex types must do the
work.  Unfortunately, this means that any constructor or method that accepts
complex c++ can't be "directly" exposed to Python.

Using both a pxd and a pyx file is done, partly, so that we can keep the
exposed c++ GeoTess functionality together in one namespace using "cimport",
and we can name the classes exposed to Python the same as those in the
GeoTess c++.

GeoTess functionality is intentionally a one-to-one translation into Python so
that any modifications to the way models and grids are used can be developed
and tested in in pure Python modules.  This makes it easier to try different
Python approaches to working with the underlying GeoTess library.

"""
from libcpp.string cimport string
from libcpp.vector cimport vector

cimport clibgeotess as clib

cdef class GeoTessGrid:
    cdef clib.GeoTessGrid *thisptr

    def __cinit__(self):
        self.thisptr = new clib.GeoTessGrid()

    def __dealloc__(self):
        del self.thisptr

    def loadGrid(self, const string& inputFile):
        self.thisptr.loadGrid(inputFile)

    def writeGrid(self, const string& fileName):
        self.thisptr.writeGrid(fileName)

    def getNLevels(self):
        return self.thisptr.getNLevels()
 
    def getNTriangles(self):
        return self.thisptr.getNTriangles()

    def getNTessellations(self):
        return self.thisptr.getNTessellations()

    def toString(self):
        return self.thisptr.toString()


cdef class GeoTessMetaData:
    cdef clib.GeoTessMetaData *thisptr

    def __cinit__(self):
        self.thisptr = new clib.GeoTessMetaData()

    def __dealloc__(self):
        del self.thisptr

    def setEarthShape(self, const string& earthShapeName):
        self.thisptr.setEarthShape(earthShapeName)

    def setDescription(self, const string& dscr):
        self.thisptr.setDescription(dscr)

    def setLayerNames(self, const string& lyrNms):
        self.thisptr.setLayerNames(lyrNms)

    def setLayerTessIds(self, vector[int]& layrTsIds):
        """
        layrTsIds is an iterable of integers.
        """
        # http://www.peterbeerli.com/classes/images/f/f7/Isc4304cpluspluscython.pdf
        self.thisptr.setLayerTessIds(layrTsIds)

    def setAttributes(self, const string& nms, const string& unts):
        self.thisptr.setAttributes(nms, unts)

    def setDataType(self, const string& dt):
        self.thisptr.setDataType(dt)

    def setModelSoftwareVersion(self, const string& swVersion):
        self.thisptr.setModelSoftwareVersion(swVersion)

    def setModelGenerationDate(self, const string& genDate):
        self.thisptr.setModelGenerationDate(genDate)

    def toString(self):
        return self.thisptr.toString()


cdef class GeoTessModel:
    cdef clib.GeoTessModel *thisptr

    def __cinit__(self, gridFileName=None, GeoTessMetaData metaData=None):
        if gridFileName is None and metaData is None:
            self.thisptr = new clib.GeoTessModel()
        else:
            if sum((gridFileName is None, metaData is None)) == 1:
                raise ValueError("Must provide both gridFileName and metaData")
            # https://groups.google.com/forum/#!topic/cython-users/6I2HMUTPT6o
            self.thisptr = new clib.GeoTessModel(gridFileName, metaData.thisptr)

    def __dealloc__(self):
        del self.thisptr

    #@staticmethod
    #cdef clib.GeoTessModel create(const string &gridFileName, clib.GeoTessMetaData *metaData):
    #    # This method is just the two-argument constructor that can accept C++ arguments
    #    cdef GeoTessModel model = GeoTessModel()
    #    model.thisptr = new clib.GeoTessModel(gridFileName, metaData)
    #    return model 

    def loadModel(self, const string& inputFile, relGridFilePath=None):
        """
        If relGridFilePath is omitted, "" is used.

        """
        # http://grokbase.com/t/gg/cython-users/128gqk22kb/default-arguments-when-wrapping-c
        # http://stackoverflow.com/questions/5081678/handling-default-parameters-in-cython
        # https://groups.google.com/forum/#!topic/cython-users/4ecKM-p8dPA
        if relGridFilePath is None:
            relGridFilePath = ""
        self.thisptr.loadModel(inputFile, relGridFilePath)

    def writeModel(self, const string& outputFile):
        self.thisptr.writeModel(outputFile)

    def toString(self):
        return self.thisptr.toString()
