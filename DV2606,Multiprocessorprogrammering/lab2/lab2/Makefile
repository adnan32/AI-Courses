# Makefile to compile .cu, .cpp, and .c files

# Compiler settings
NVCC := nvcc
GCC := gcc
GPP := g++

# Compiler flags
NVCC_FLAGS := -std=c++11
GCC_FLAGS := -O2
GPP_FLAGS := -std=c++0x -O2

# File extensions
CU_EXT := .cu
CPP_EXT := .cpp
C_EXT := .c

# Source files
CU_FILES := $(wildcard *$(CU_EXT))
CPP_FILES := $(wildcard *$(CPP_EXT))
C_FILES := $(wildcard *$(C_EXT))

# Object files
CU_OBJS := $(CU_FILES:$(CU_EXT)=.o)
CPP_OBJS := $(CPP_FILES:$(CPP_EXT)=.o)
C_OBJS := $(C_FILES:$(C_EXT)=.o)

# Default target
all: $(CU_OBJS) $(CPP_OBJS) $(C_OBJS)

# Compile .cu files
%.o: %$(CU_EXT)
	$(NVCC) -o $@ $< $(NVCC_FLAGS)

# Compile .cpp files
%.o: %$(CPP_EXT)
	$(GPP) -o $@ $< $(GPP_FLAGS)

# Compile .c files
%.o: %$(C_EXT)
	$(GCC) -o $@ $< $(GCC_FLAGS)

# Clean
clean:
	rm -f $(CU_OBJS) $(CPP_OBJS) $(C_OBJS)
