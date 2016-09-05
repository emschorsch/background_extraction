# Base image heroku cedar stack v14
#FROM heroku/cedar:14
# Inherit from Heroku's python stack
FROM heroku/python

# Remove all system python interpreters
RUN apt-get remove -y python2.7
RUN apt-get remove -y python3.4
RUN apt-get remove -y python2.7-minimal
RUN apt-get remove -y python3.4-minimal
RUN apt-get remove -y libpython2.7-minimal
RUN apt-get remove -y libpython3.4-minimal

# Install and add multiverse
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty multiverse' >> /etc/apt/sources.list
RUN apt-get update

# remove ffmpeg
RUN apt-get remove -y ffmpeg x264 libx264-dev

# Install opencv dependencies from http://www.samontab.com/web/2011/06/installing-opencv-2-4-1-in-ubuntu-12-04-lts/
RUN apt-get install -y build-essential libgtk2.0-dev libjpeg-dev libtiff4-dev libjasper-dev libopenexr-dev cmake python-dev python-numpy libtbb-dev libeigen2-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libavcodec-dev libavformat-dev libswscale-dev

#build-essential libgtk2.0-dev libjpeg-dev libtiff4-dev libjasper-dev libopenexr-dev cmake python-dev python-numpy python-tk libtbb-dev libeigen2-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libqt4-dev libqt4-opengl-dev sphinx-common libv4l-dev libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev

# Make folder structure
RUN mkdir -p /app
RUN mkdir -p /app/.heroku
RUN mkdir -p /app/.heroku/vendor
RUN mkdir -p /app/.heroku/ffmpeg
WORKDIR /app/.heroku


# Install python 2.7.12
ENV PATH /app/.heroku/vendor/bin:$PATH
ENV LD_LIBRARY_PATH /app/.heroku/vendor/lib/
ENV PYTHONPATH /app/.heroku/vendor/lib/python2.7/site-packages
RUN curl -s -L https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz > Python-2.7.12.tgz
RUN tar zxvf Python-2.7.12.tgz
RUN rm Python-2.7.12.tgz
WORKDIR /app/.heroku/Python-2.7.12
# --enable-static isn't recognized, just generates warning
RUN ./configure --prefix=/app/.heroku/vendor/ --enable-shared --enable-static
RUN make install
WORKDIR /app/.heroku
RUN rm -rf Python-2.7.12


# Install latest setup-tools and pip
RUN curl -s -L https://bootstrap.pypa.io/get-pip.py > get-pip.py
RUN python get-pip.py
RUN rm get-pip.py


# Install numpy
RUN pip install -v numpy


# Install ATLAS library and fortran compiler
RUN curl -s -L https://db.tt/osV4nSh0 > npscipy.tar.gz
RUN tar zxvf npscipy.tar.gz
RUN rm npscipy.tar.gz
ENV ATLAS /app/.heroku/vendor/lib/atlas-base/libatlas.a
ENV BLAS /app/.heroku/vendor/lib/atlas-base/atlas/libblas.a
ENV LAPACK /app/.heroku/vendor/lib/atlas-base/atlas/liblapack.a
ENV LD_LIBRARY_PATH /app/.heroku/vendor/lib/atlas-base:/app/.heroku/vendor/lib/atlas-base/atlas:$LD_LIBRARY_PATH
RUN apt-get update
RUN apt-get install -y gfortran


# Install scipy
RUN pip install -v scipy


# Install matplotlib
# RUN apt-get install -y libfreetype6-dev
# RUN apt-get install -y libpng-dev
RUN pip install -v matplotlib

# Install opencv with python bindings
RUN apt-get update
RUN apt-get install -y cmake
RUN curl -s -L https://github.com/Itseez/opencv/archive/2.4.11.zip > opencv-2.4.11.zip
RUN unzip opencv-2.4.11.zip
RUN rm opencv-2.4.11.zip
WORKDIR /app/.heroku/opencv-2.4.11
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/app/.heroku/vendor -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=OFF -D BUILD_DOCS=OFF -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D WITH_QT=OFF -D WITH_OPENGL=OFF -D WITH_VTK=OFF -D BUILD_opencv_python=ON .


RUN make install
WORKDIR /app/.heroku
RUN rm -rf opencv-2.4.11

CMD gunicorn ceder14-opencv-test3.wsgi --log-file -