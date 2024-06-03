#!/usr/bin/env bash
docker kill ghdl_runner || true && docker run  --name ghdl_runner -it --rm -v "$(pwd)":/pwd ghdl_runner_image_djosh34 sh -c "make -f matrix_2_output/Makefile"
# docker kill ghdl_runner || true && docker run  --name ghdl_runner -it --rm -v "$(pwd)":/pwd ghdl_runner_image_djosh34 sh -c "make -f xnor_popcount/Makefile"
