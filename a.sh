#!/bin/bash

cp publisher/index_root.html .
cp publisher/errors.html .

v run publishtools.v run

rm -f index_root.html
rm -f errors.html
