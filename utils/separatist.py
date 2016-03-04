#!/usr/bin/env python
# -*- coding: utf-8 -*-
# separatist.py
# Johannes Burström 2016

# Given a sound file, and a file with one time value per line (sorted), creates a master attack file
# and n sustain files. 
# Needs sox.

import os
import sys
import subprocess

# OPTIONS
LENGTH="0.1" #as string
OUTDIR="out" #out dir, relative 


#path to file and a list of onset times
def trim_file(path, outpath, list):
    subprocess.call(["sox", path, outpath, "trim"] + list);

def make_onset_list(path):
    #First list is segment attack
    #Second list is rest of segment
    output = [[]]
    starts = []
    ends = []
    first = True
    with open(path) as f:
        for line in f:
            output[0].append("="+line.split()[0])
            output[0].append(LENGTH)
            starts.append("=" + str(float(line.split()[0]) + float(LENGTH)))
            if not first:
                ends.append("="+line.split()[0])
            first = False

    #Make the last onset continue to the end
    ends.append("-0")

    output.append(zip(starts,ends))
    #output list of arguments
    return output

if __name__ == '__main__':
    audiopath = sys.argv[1];
    listpath = sys.argv[2];
    onsets, sustains = make_onset_list(listpath);

    #Make a file with attacks 
    (base, ext) = os.path.splitext(audiopath)
    (basename, filename) = os.path.split(base)
    base = os.path.join(basename, OUTDIR, filename)
    attpath = "{1}-{0}{2}".format("att", base, ext)
    trim_file(audiopath, attpath, onsets);
    for i, tuple in enumerate(sustains):
        suspath = "{2}-{0}-{1}{3}".format("sus", i, base, ext)
        trim_file(audiopath, suspath, list(tuple));


