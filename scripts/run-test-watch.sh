#!/bin/bash

find .. -name "*.dart" | entr flutter test
