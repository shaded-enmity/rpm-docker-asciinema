#!/bin/bash

tar -cf context.tar *
rpmbuild -tb context.tar
rm -f context.tar
