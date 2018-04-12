#!/bin/bash


. ./cmd.sh
. ./path.sh

# you might not want to do this for interactive shells.
set -e

#Audio –> Feature Vectors

compute-mfcc-feats \
    --config=conf/mfcc.conf \
    scp:transcriptions/wav.scp \
    ark,scp:transcriptions/feats.ark,transcriptions/feats.scp


#Trained CNN + Feature Vectors –> Lattice

nnet-latgen-faster \
    --word-symbol-table=tri3b/exp/tri3b/graph_nosp_tgsmall/words.txt \
    cnn4c_pretrain-dbn_dnn/exp/cnn4c_pretrain-dbn_dnn/final.mdl \
    tri3b/exp/tri3b/graph_nosp_tgsmall/HCLG.fst \
    ark:transcriptions/feats.ark \
    ark,t:transcriptions/lattices.ark;

 #Lattice –> Best Path Through Lattice

lattice-best-path \
    --word-symbol-table=tri3b/exp/tri3b/graph_nosp_tgsmall/words.txt \
    ark:transcriptions/lattices.ark \
    ark,t:transcriptions/one-best.tra;



#Best Path Intergers –> Best Path Words

utils/int2sym.pl -f 2- \
    tri3b/exp/tri3b/graph_nosp_tgsmall/words.txt \
    transcriptions/one-best.tra \
    > transcriptions/one-best-hypothesis.txt;


 #transcriptions/one-best-hypothesis.txt
