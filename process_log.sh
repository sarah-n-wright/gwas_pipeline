awk -v start=$report_start -v out=$out '/variants loaded from .bim file/ {if (NR > start) print "nVariants" "\t" $2 > out}' $1
awk -v start=$report_start -v out=$out '/[0123456789]+ people \(/ {if (NR > start) print "nPeople" "\t" $2 > out}' $1
#report_start=($(wc -l $1))
