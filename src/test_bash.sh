#!/bin/bash

NUM_CPU=$(nproc)
OUTFILE="output_test.txt"
# Svuota il file se esiste
> "$OUTFILE"

key="Chiave segreta"
mode=0
DIR="TestFiles/Input"

files=("$DIR"/*)
ls "$DIR"
# Stampa i nomi
for f in "${files[@]}"; do
    echo "$f"
done
: '
Modalità di compressione:
    0 = Huffman\n
    1 = Arithmetic Coding\n
    2 = LZW\n
    3 = BZip2
'
for i in "${!files[@]}"; do
    files[$i]=$(basename "${files[$i]}")
done

for f in "${files[@]}"; do
    echo "==============================" | tee -a "$OUTFILE"
    echo " ITERAZIONE SUL FILE $f" || tee -a "$OUTFILE"
    echo "==============================" | tee -a "$OUTFILE"
    for i in {1..3}; do
        echo "==============================" | tee -a "$OUTFILE"
        echo " ITERAZIONE $i - tester_mpi" | tee -a "$OUTFILE"
        echo "==============================" | tee -a "$OUTFILE"

        mpirun -np "$NUM_CPU" --oversubscribe python3 tester_MPI.py "$f" "$key" "$mode" | tee -a "$OUTFILE" 2>&1

        echo "" || tee -a "$OUTFILE"
        echo "==============================" | tee -a "$OUTFILE"
        echo " ITERAZIONE $i - tester" || tee -a "$OUTFILE"
        echo "==============================" | tee -a "$OUTFILE"

        python3 tester.py "$f" "$key" "$mode" | tee -a "$OUTFILE" 2>&1

        echo "" || tee -a "$OUTFILE"
        echo "==============================" | tee -a "$OUTFILE"
        echo " ITERAZIONE $i - tester_bzip" | tee -a "$OUTFILE"
        echo "==============================" | tee -a "$OUTFILE"

        python3 tester_bzip.py "$f" | tee -a "$OUTFILE" 2>&1
        echo "" | tee -a "$OUTFILE"
    done

done
echo "Test completati. Risultati salvati in $OUTFILE"