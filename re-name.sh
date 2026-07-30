#for files have wrong names
#Source_subID	Source_sesID	Correct_subID	Correct_sesID
#304	baseline1	304	repeatbaseline
#132	baseline1	132	baseline
#141	baseline1	141	T12
#326	T12	325	T12
#326	T121	326	T12
#26.04.14-10_09_5139	T6	139	T6
#25.03.31-10_52_3111	baseline	111	baseline
#25.01.16-15_38_5104	baseline	104	baseline
#26.04.24-10_01_4153	baseline	153	baseline
cd /gscratch/scrubbed/fanglab/xiaoqian/IFOCUS/sourcedata/nii

find sub-304/ses-baseline1 -type f -name '*baseline1*' | while read -r f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    mv "$f" "$dir/${base//baseline1/repeatbaseline}"
done

#rm sub-132 ses-baseline first
find sub-132/ses-baseline1 -type f -name '*baseline1*' | while read -r f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    mv "$f" "$dir/${base//repeatbaseline/baseline}"
done

find sub-141/ses-baseline1 -type f -name '*baseline1*' | while read -r f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    mv "$f" "$dir/${base//baseline1/T12}"
done

find sub-326/ses-T12 -type f -name '*sub-326*' | while read -r f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    mv "$f" "$dir/${base//sub-326/sub-325}"
done

find sub-326/ses-T121 -type f -name '*ses-T121*' | while read -r f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    mv "$f" "$dir/${base//ses-T121/ses-T12}"
done




