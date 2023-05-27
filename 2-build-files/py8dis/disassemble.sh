rm source-files/*.asm

python py8dis-scripts/elite-source-bank-0.py > source-files/elite-source-bank-0.asm
python py8dis-scripts/elite-source-bank-1.py > source-files/elite-source-bank-1.asm
python py8dis-scripts/elite-source-bank-2.py > source-files/elite-source-bank-2.asm
python py8dis-scripts/elite-source-bank-3.py > source-files/elite-source-bank-3.asm
python py8dis-scripts/elite-source-bank-4.py > source-files/elite-source-bank-4.asm
python py8dis-scripts/elite-source-bank-5.py > source-files/elite-source-bank-5.asm
python py8dis-scripts/elite-source-bank-6.py > source-files/elite-source-bank-6.asm
python py8dis-scripts/elite-source-bank-7.py > source-files/elite-source-bank-7.asm

# Append final byte from $FFFF as py8dis fails if $FFFF is populated

sed -i "" -e "s/STA pydis_end/STA \&FFFF    /" source-files/elite-source-bank-7.asm
sed -i "" -e "s/\.pydis_end/    EQUB \&CE\n.pydis_end/" source-files/elite-source-bank-7.asm

# Copy results into main-sources

#rm ../../1-source-files/main-sources/elite-source-bank-0.asm
#rm ../../1-source-files/main-sources/elite-source-bank-1.asm
#rm ../../1-source-files/main-sources/elite-source-bank-2.asm
#rm ../../1-source-files/main-sources/elite-source-bank-3.asm
#rm ../../1-source-files/main-sources/elite-source-bank-4.asm
#rm ../../1-source-files/main-sources/elite-source-bank-5.asm
#rm ../../1-source-files/main-sources/elite-source-bank-6.asm
#rm ../../1-source-files/main-sources/elite-source-bank-7.asm

#cat headers/header.asm source-files/elite-source-bank-0.asm headers/footer.asm > ../../1-source-files/main-sources/elite-source-bank-0.asm
#cat headers/header.asm source-files/elite-source-bank-1.asm headers/footer.asm > ../../1-source-files/main-sources/elite-source-bank-1.asm
#cat headers/header.asm source-files/elite-source-bank-2.asm headers/footer.asm > ../../1-source-files/main-sources/elite-source-bank-2.asm
#cat headers/header.asm source-files/elite-source-bank-3.asm headers/footer.asm > ../../1-source-files/main-sources/elite-source-bank-3.asm
#cat headers/header.asm source-files/elite-source-bank-4.asm headers/footer.asm > ../../1-source-files/main-sources/elite-source-bank-4.asm
#cat headers/header.asm source-files/elite-source-bank-5.asm headers/footer.asm > ../../1-source-files/main-sources/elite-source-bank-5.asm
#cat headers/header.asm source-files/elite-source-bank-6.asm headers/footer.asm > ../../1-source-files/main-sources/elite-source-bank-6.asm
#cat headers/header.asm source-files/elite-source-bank-7.asm headers/footer.asm > ../../1-source-files/main-sources/elite-source-bank-7.asm

#sed -i "" -e "s/NES ELITE GAME SOURCE (BANK 0)/NES ELITE GAME SOURCE (BANK 1)/" ../../1-source-files/main-sources/elite-source-bank-1.asm
#sed -i "" -e "s/NES ELITE GAME SOURCE (BANK 0)/NES ELITE GAME SOURCE (BANK 2)/" ../../1-source-files/main-sources/elite-source-bank-2.asm
#sed -i "" -e "s/NES ELITE GAME SOURCE (BANK 0)/NES ELITE GAME SOURCE (BANK 3)/" ../../1-source-files/main-sources/elite-source-bank-3.asm
#sed -i "" -e "s/NES ELITE GAME SOURCE (BANK 0)/NES ELITE GAME SOURCE (BANK 4)/" ../../1-source-files/main-sources/elite-source-bank-4.asm
#sed -i "" -e "s/NES ELITE GAME SOURCE (BANK 0)/NES ELITE GAME SOURCE (BANK 5)/" ../../1-source-files/main-sources/elite-source-bank-5.asm
#sed -i "" -e "s/NES ELITE GAME SOURCE (BANK 0)/NES ELITE GAME SOURCE (BANK 6)/" ../../1-source-files/main-sources/elite-source-bank-6.asm
#sed -i "" -e "s/NES ELITE GAME SOURCE (BANK 0)/NES ELITE GAME SOURCE (BANK 7)/" ../../1-source-files/main-sources/elite-source-bank-7.asm

#sed -i "" -e "s/bank0/bank1/" ../../1-source-files/main-sources/elite-source-bank-1.asm
#sed -i "" -e "s/bank0/bank2/" ../../1-source-files/main-sources/elite-source-bank-2.asm
#sed -i "" -e "s/bank0/bank3/" ../../1-source-files/main-sources/elite-source-bank-3.asm
#sed -i "" -e "s/bank0/bank4/" ../../1-source-files/main-sources/elite-source-bank-4.asm
#sed -i "" -e "s/bank0/bank5/" ../../1-source-files/main-sources/elite-source-bank-5.asm
#sed -i "" -e "s/bank0/bank6/" ../../1-source-files/main-sources/elite-source-bank-6.asm
#sed -i "" -e "s/bank0/bank7/" ../../1-source-files/main-sources/elite-source-bank-7.asm

#sed -i "" -e "s/SAVE pydis_start, pydis_end//" ../../1-source-files/main-sources/elite-source-bank-0.asm
#sed -i "" -e "s/SAVE pydis_start, pydis_end//" ../../1-source-files/main-sources/elite-source-bank-1.asm
#sed -i "" -e "s/SAVE pydis_start, pydis_end//" ../../1-source-files/main-sources/elite-source-bank-2.asm
#sed -i "" -e "s/SAVE pydis_start, pydis_end//" ../../1-source-files/main-sources/elite-source-bank-3.asm
#sed -i "" -e "s/SAVE pydis_start, pydis_end//" ../../1-source-files/main-sources/elite-source-bank-4.asm
#sed -i "" -e "s/SAVE pydis_start, pydis_end//" ../../1-source-files/main-sources/elite-source-bank-5.asm
#sed -i "" -e "s/SAVE pydis_start, pydis_end//" ../../1-source-files/main-sources/elite-source-bank-6.asm
#sed -i "" -e "s/SAVE pydis_start, pydis_end//" ../../1-source-files/main-sources/elite-source-bank-7.asm

#sed -i "" -e "s/\&8000/\&C000/" ../../1-source-files/main-sources/elite-source-bank-7.asm

# Build resulting sources

#cd ../../../../
#make nes
