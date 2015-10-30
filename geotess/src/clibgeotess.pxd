"""
This module pulls GeoTess c++ functionality into Cython (not Python yet).

We pull from all of GeoTess into this one place, and only the desired classes,
methods, and functions.  Declarations are unchanged from the original.

"""
from libcpp.string cimport string

cdef extern from "GeoTessGrid.h" namespace "geotess":
    cdef cppclass GeoTessGrid:
        GeoTessGrid() except +
        # string value inputFile is turned into a pointer, that can't be used to
        # modify the thing it points to, and returns a pointer to a GeoTessGrid.
        GeoTessGrid* loadGrid(const string& inputFile)
        void writeGrid(const string& fileName)
        int getNLevels()
        int getNTriangles()
        int getNTessellations()
        string toString()

cdef extern from "GeoTessMetaData.h" namespace "geotess":
    cdef cppclass GeoTessMetaData:
        GeoTessMetaData() except +
        void setEarthShape(const string& earthShapeName)
        void setDescription(const string& dscr)
        void setLayerNames(const string& lyrNms)
        void setAttributes(const string& nms, const string& unts)
        void setDataType(const string& dt)
        void setModelSoftwareVersion(const string& swVersion)
        void setModelGenerationDate(const string& genDate)

cdef extern from "GeoTessModel.h" namespace "geotess":
    cdef cppclass GeoTessModel:
        GeoTessModel() except +
        # methods with default must be declared multiple times with explicit
        # params, and routed in the Python-exposed pyx file.
        GeoTessModel* loadModel(const string& inputFile, const string& relGridFilePath)
        void writeModel(const string &outputFile)
        string toString()
