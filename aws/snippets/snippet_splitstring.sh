# split a space delimited string
teststring="apple banana orange"
testarray=$(echo $teststring | tr " " "\n")
for i in $testarray
do
 echo found $i
done
