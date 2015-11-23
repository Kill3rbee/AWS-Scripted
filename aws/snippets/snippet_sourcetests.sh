#!/bin/bash

# write a test script
echo '#!/bin/bash' > test.sh
echo 'echo input=$input' >> test.sh
echo 'output=output' >> test.sh
chmod +x test.sh

# set a variable in the top context
input=input
echo input=$input

# show that output is empty
echo output=$output

# run just the filename (we get an error)
echo running: test.sh
test.sh

# run ./ version
echo running: ./test.sh
./test.sh
echo output=$output
# reset output
unset output

# run . ./ version
echo running: . ./test.sh
. ./test.sh
echo output=$output
# reset output
unset output

# run source ./ version
echo running: source ./test.sh
source ./test.sh
echo output=$output
# reset output
unset output

# run source version
echo running: source test.sh
source test.sh
echo output=$output
# reset output
unset output
