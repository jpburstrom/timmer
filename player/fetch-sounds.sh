#!/bin/sh

git annex init &&
git annex upgrade &&
git annex enableremote timmers3 &&
git annex sync --content
