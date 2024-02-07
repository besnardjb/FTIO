<!-- # FTIO -->
![license][license.bedge]
![Coveralls branch](https://img.shields.io/coverallsCoverage/github/tuda-parallel/FTIO)
![GitHub Release](https://img.shields.io/github/v/release/tuda-parallel/FTIO)
![issues](https://img.shields.io/github/issues/tuda-parallel/FTIO)
![contributors](https://img.shields.io/github/contributors/tuda-parallel/FTIO)
<!-- ![GitHub pull requests](https://img.shields.io/github/issues-pr/tuda-parallel/FTIO) -->

<br />
<div align="center">
<!-- TODO: Add logo -->
  <!-- <a href="https://git.rwth-aachen.de/parallel/ftio">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

  <h1 align="center">FTIO</h1>
  <p align="center">
	<h3 align="center"> Frequency Techniques for I/O </h2>
    <!-- <br /> -->
    <a href="https://github.com/tuda-parallel/FTIO/tree/main/docs/approach.md"><strong>Explore the approach »</strong></a>
    <br />
    <!-- <br /> -->
    <a href="https://git.rwth-aachen.de/parallel/ftio">View Demo</a>
    ·
    <a href="https://github.com/tuda-parallel/FTIO/issues">Report Bug</a>
    ·
    <a href="https://github.com/tuda-parallel/FTIO/issues">Request Feature</a>
  </p>
</div>


FTIO captures periodic I/O using frequency techniques. 
Many high-performance computing (HPC) applications perform their I/O in bursts following a periodic pattern. 
Predicting such patterns can be very efficient for I/O contention avoidance strategies, including burst buffer management, for example. 
FTIO allows [*offline* detection](/docs/approach.md#offline-detection) and [*online* prediction](/docs/approach.md#online-prediction) of periodic I/O phases. 
FTIO uses the discrete Fourier transform (DFT), combined with outlier detection methods to extract the dominant frequency in the signal. 
Additional metrics gauge the confidence in the output and tell how far from being periodic the signal is. 
A complete description of the approach is provided [here](https://github.com/tuda-parallel/FTIO/tree/main/docs/approach.md).


This repository provides two main Python-based tools: 
- [`ftio`](/docs/approach.md#offline-detection):  uses frequency techniques, outlier detection methods to find the period of I/O 
- [`predictor`](/docs/approach.md#online-prediction): implements the online version of FTIO. It simply reinvokes FTIO whenever new traces are appended to the monitored file. See [online prediction](/docs/approach.md#online-prediction) for more details. We recommend using [TMIO](https://github.com/tuda-parallel/TMIO) to generate the file with the I/O traces.


Other tools:
- [`ioplot`](https://github.com/tuda-parallel/FTIO/tree/main/docs/approach.md) generates interactive plots in HTML
- [`parse`](https://github.com/tuda-parallel/FTIO/tree/main/docs/approach.md) parses and merges several traces to an [Extra-P](https://github.com/extra-p/extrap) supported format. This allows to examine the scaling behavior of the monitored metrics. Traces generated by FTIO (frequency modls), [TMIO](https://github.com/tuda-parallel/FTIO) (msgpack, json and jsonl) and other tools (Darshan, Recorder, and TAU Metric Proxy) are supported. 



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#installation">Installation</a>
      <ul>
        <li><a href="#automated-installation">Automated installation</a></li>
        <li><a href="#manual-installation">Manual installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
	<li><a href="#testing">Testing</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
	<li><a href="#citation">Citation</a></li>
	<li><a href="#publications">Publications</a></li>
  </ol>
</details>

Join the [Slack channel](https://join.slack.com/t/ftioworkspace/shared_invite/zt-2bydqdt13-~hIHzIrKW2zJY_ZWJ5oE_g) or see latest updates here: [Latest News](https://github.com/tuda-parallel/FTIO/tree/main/ChangeLog.md)


## Installation

FTIO can be installed either [automatically](#automated-installation) or [manually](#manual-installation). 


### Automated installation

Simply call the make command:

```sh
make install
```

This generates a virtual environment in the current directory, sources `.venv/bin/activate`, and installs FTIO as a module. 

If you don't need a dedicated environment, simply call:

```sh
make ftio
```


### Manual installation

Create a virtual environment if needed and activate it:

```sh
python3 -m venv .venv
source .venv/bin/activate
```

Install all tools provided in this repo simply by using pip:

```sh
pip install .
```

Note: you need to activate the environment to use `ftio` and the other tools using:

```sh
source path/to/venv/bin/activate
```

<p align="right"><a href="#ftio">⬆</a></p>

## Usage
For installation instructions see [installation](#installation).

To call `ftio` on a single file, use:
```sh
ftio filename.extension
```

Supported extensions are `json`, `jsonLines`, `msgpack`, and `darshan`. For recorder, provide the path to the folder instead of `filename.extension`. 

FTIO provides various options and extensions. To see all available command line arguments, call:

```
ftio -h

  
usage: ftio [-h] [-m MODE] [-r RENDER] [-f FREQ] [-ts TS] [-te TE] [-tr TRANSFORMATION] [-e ENGINE]
            [-o OUTLIER] [-le LEVEL] [-t TOL] [-d] [-nd] [-re] [--no-reconstruction] [-p] [-np] [-c] [-w]
            [-fh FREQUENCY_HITS] [-v] [-s] [-ns] [-a] [-na] [-i] [-ni] [-x DXT_MODE] [-l LIMIT]
            files [files ...]
```

`ftio` generates frequency predictions. There are several options available to enhance the predictions. In the standard mode, the DFT is used in combination with an outlier detection method. Additionally, autocorrelation can be used to further increase the confidence in the results:

1. DFT + outlier detection (Z-score, DB-Scan, Isolation forest, peak detection, or LOF)​
2. Optionally: Autocorrelation + Peak detection (`-c` flag)
3. If 2. is performed, merge results from both predictions automatically

Several flags can be specified. The most relevant settings are:

| Flag                        | Description|
|---                          | --- |
|file                         | file, file list (file 0 ... file n), folder, or folder list (folder 0.. folder n) containing traces  (positional argument)|
|-h, --help                   | show this help message and exit|
|-m MODE, --mode MODE         | if the trace file contains several I/O modes, a specific mode can be selected. Supported modes are: async_write, async_read, sync_write, sync_read|
|-r RENDER, --render RENDER   | specifies how the plots are rendered. Either dynamic (default) or static|
|-f FREQ, --freq FREQ         | specifies the sampling rate with which the continuous signal is discretized (default=10Hz). This directly affects the highest captured frequency (Nyquist). The value is specified in Hz. In case this value is set to -1, the auto mode is launched which sets the sampling frequency automatically to the smallest change in the bandwidth detected. Note that the lowest allowed frequency in the auto mode is 2000 Hz|
|-ts TS, --ts TS              | Modifies the start time of the examined time window
|-te TE, --te TE              | Modifies the end time of the examined time window
|-tr TRANSFORMATION, --transformation TRANSFORMATION| specifies the frequency technique to use. Supported modes are: dft (default), wave_disc, and wave_cont|
|-e ENGINE, --engine ENGINE   | specifies the engine used to display the figures. Either plotly (default) or mathplotlib can be used. Plotly is used to generate interactive plots as HTML files. Set this value to no if you do not want to generate plots
|-o OUTLIER, --outlier OUTLIER| outlier detection method: Z-score (default), DB-Scan, Isolation_forest, or LOF|
|-le LEVEL, --level LEVEL     | specifies the decomposition level for the discrete wavelet transformation (default=3). If specified as auto, the maximum decomposition level is automatic calculated |
|-t TOL, --tol TOL            | tolerance value|
|-d, --dtw                    | performs dynamic time wrapping on the top 3 frequencies (highest contribution) calculated using the DFT if set (default=False) |
|-re, --reconstruction        | plots reconstruction of top 10 signals on figure |
|-np, --no-psd                | if set, replace the power density spectrum (a*a/N) with the amplitude spectrum (a) |
|-c, --autocorrelation        | if set, autocorrelation is calculated in addition to DFT. The results are merged to a single prediction at the end |
|-w, --window_adaptation      | online time window adaptation. If set to true, the time window is shifted on X hits to X times the previous phases from the current instance. X corresponds to frequency_hits|
|-fh FREQUENCY_HITS, --frequency_hits FREQUENCY_HITS |  specifies the number of hits needed to adapt the time window. A hit occurs once a dominant frequency is found|
|-v, --verbose                | sets verbose on or off (default=False)|
|-x DXT_MODE, --dxt_mode DXT_MODE| select data to extract from darshan traces (DXT_POSIX or DXT_MPIIO (default)) |
|-l LIMIT, --limit LIMIT         | max ranks to consider when reading a folder |


`predictor` has the same syntax as `ftio`. 
All arguments that are available for `ftio` are also available for `predictor`.

<p align="right"><a href="#ftio">⬆</a></p>

## Testing
There is a `8.jsonl` file provided for testing under [examples](https://github.com/tuda-parallel/FTIO/examples). Here just call:

```sh
ftio 8.jsonl
```
<p align="right"><a href="#ftio">⬆</a></p>

<!-- CONTRIBUTING -->
## Contributing

If you have a suggestion that would make this better, please fork the repo and create a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right"><a href="#ftio">⬆</a></p>



<!-- CONTACT -->
## Contact
[![][parallel.bedge]][parallel_website]
- Ahmad Tarraf: <ahmad.tarraf@tu-darmstadt.de>


  

<p align="right"><a href="#ftio">⬆</a></p>


## License
![license][license.bedge]

Distributed under the BSD 3-Clause License. See [LISCENCE](./LICENSE) for more information.
<p align="right"><a href="#ftio">⬆</a></p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments
Authors: 
  - Ahmad Tarraf
  - Add your name here

This work is a result of a coopertion between the Technical University of Darmstadt 
and INRIA. 

<p align="right"><a href="#ftio">⬆</a></p>

## Citation:
```
 @inproceedings{Tarraf_Bandet_Boito_Pallez_Wolf_2024, 
 	author={Tarraf, Ahmad and Bandet, Alexis and Boito, Francieli and Pallez, Guillaume and Wolf, Felix},
 	title={Capturing Periodic I/O Using Frequency Techniques}, 
 	booktitle={2024 IEEE International Parallel and Distributed Processing Symposium (IPDPS)}, 
 	address={San Francisco, CA, USA}, 
 	year={2024},
 	month=may, 
 	pages={1–14}, 
 	notes = {(accepted)}
 }
```
<p align="right"><a href="#ftio">⬆</a></p>


## Publications:
1. A. Tarraf, A. Bandet, F. Boito, G. Pallez, and F. Wolf, “Capturing Periodic I/O Using Frequency Techniques,” in 2024 IEEE International Parallel and Distributed Processing Symposium (IPDPS), San Francisco, CA, USA, May 2024, pp. 1–14.

2. A. Tarraf, A. Bandet, F. Boito, G. Pallez, and F. Wolf, “FTIO: Detecting I/O periodicity using frequency techniques.” 2023.


<p align="right"><a href="#ftio">⬆</a></p>



[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 


<!-- https://img.shields.io/badge/any_text-you_like-blue -->

<!--* Badges *-->
[pipeline.badge]: https://git.rwth-aachen.de/parallel/ftio/badges/main/pipeline.svg
[coverage.badge]: https://git.rwth-aachen.de/parallel/ftio/badges/main/coverage.svg
[python.bedge]: https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54
[license.bedge]: https://img.shields.io/badge/License-BSD_3--Clause-blue.svg
[linkedin.bedge]: https://img.shields.io/badge/LinkedIn-0077B5?tyle=for-the-badge&logo=linkedin&logoColor=white
[linkedin.profile]: https://www.linkedin.com/in/dr-ahmad-tarraf-8b6942118
[parallel_website]: https://www.parallel.informatik.tu-darmstadt.de/laboratory/team/tarraf/tarraf.html
[parallel.bedge]: https://img.shields.io/badge/Parallel_Programming:-Ahmad_Tarraf-blue
[pull.bedge]: https://img.shields.io/github.com/tuda-parallel/FTIO/pulls


<!--* links *-->
[issue]: https://github.com/tuda-parallel/FTIO/issues
[pull]: https://github.com/tuda-parallel/FTIO/pulls
[insight]: https://github.com/tuda-parallel/FTIO/network/dependencies