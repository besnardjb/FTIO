PYTHON = .venv/bin/python3
SHELL := /bin/bash

#check if python exist in venv, otherwise fallback to default
ifeq ("${PYTHON}",".venv/bin/python3")
ifeq ("$(wildcard ${PYTHON})","")
$(warning Python not found in .venv, falling back to default)
PYTHON=python3
endif
else 
$(info Using python: ${PYTHON})
endif

all: install  



install: venv clean ftio msg 

debug: venv ftio_debug msg 

ftio_debug: 
	mv old_setup setup.py
	mv pyproject.toml old_pyproject
	${PYTHON} -m pip install -e . || (mv old_pyproject pyproject.toml && mv setup.py old_setup)
	mv old_pyproject pyproject.toml
	mv setup.py old_setup
	

ftio: 
	${PYTHON} -m pip install . 

venv: 
	${PYTHON} -m venv .venv 


msg: 
	@echo -e "\nftio was installed in an python environment in .venv" 
	@echo -e "To activate python from this venv, call:\nsource $(PWD)/.venv/bin/activate\n"
	@echo -e "Afterwards, you can just call 'ftio [filename]'"

clean:
	echo "Cleaning old installation"
	${PYTHON} -m pip uninstall --yes ftio-hpc || echo "no installation of ftio found"

clean_all: clean
	rm -rf .venv


docker:
	cd docker && docker build -t freq_io:1.0 .


docker_run:
	cd docker && docker run -v "$$PWD/examples/tmio/JSONL/8.jsonl:/freq_io/8.jsonl" -t freq_io:1.0 ftio 8.jsonl -e no 


docker_interactive:
	cd docker && docker run -ti   freq_io:1.0



# profile 
profile:
	rm -f test.pstats
	${PYTHON} -m cProfile -o test.pstats ftio/cli/ftio_core.py -h
	${PYTHON} -m pip install snakeviz
	snakeviz test.pstats

profile2:
	${PYTHON} -m pip install pyinstrument
	${PYTHON} -m pyinstrument ftio/cli/ftio_core.py  -h

# test
test_all:
	mkdir quicktest
	cp examples/tmio/JSONL/8.jsonl quicktest
	@cd quicktest && ftio 8.jsonl -e no && echo "--- passed ftio ---" || echo "--- failed ftio ---"
	@cd quicktest && ftio 8.jsonl -e no -o dbscan && echo "--- passed ftio ---" || echo "--- failed ftio ---"
	@cd quicktest && ftio 8.jsonl -e no -o lof && echo "--- passed ftio ---" || echo "--- failed ftio ---"
	@cd quicktest && ioparse 8.jsonl && echo "--- passed ioparse ---" || echo "--- failed ioparse ---"
	@cd quicktest && ioplot 8.jsonl --no_disp && echo "--- passed ioplot ---" || echo "--- failed ioplot ---"
	@rm -rf ./quicktest/*

test:
	cd test && python3 -m pytest && make clean

quick_test:
	$(PWD)/.venv/bin/ftio -e no -h 


# publish
testpypi: build
	${PYTHON} -m pip install --upgrade twine
	${PYTHON} -m twine upload --repository testpypi dist/*

testpypi-install:	
	${PYTHON} -m pip install --index-url https://test.pypi.org/simple/ --no-deps ftio_hpc

pypi: build
	${PYTHON} -m pip install --upgrade twine
	${PYTHON} -m twine upload --repository testpypi dist/*
	${PYTHON} -m pip install ftio_hpc

build: pack

pack:
	${PYTHON} -m  pip install --upgrade pip
	${PYTHON} -m  pip install --upgrade build 
	${PYTHON} -m build


.PHONY: all test test_all clean clean_all build pack testpypi ftio
