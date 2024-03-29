#!/bin/bash

printf "len\ttc\tintersection\tunion\tjaccard\tn_intersections\n" > matrix3D.txt

while IFS=" " read len tc
do
    cat LOGS/log.$len.$tc.txt >> matrix3D.txt
done < combinations.txt