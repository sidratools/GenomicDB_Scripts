# GenomicDB_Scripts
Generate the configuration files (CallSet.json and LoaderConfiguration.json) to run the GenomicDB application

#
# Copyright (c) 2017 SIDRA Medical and Research Center, Biomedical Informatics, Doha, Qatar
# Authors:
#             Ramzi Temanni <rtemanni@sidra.org>
#             Nagarajan Kathiresan <nkathiresan@sidra.org>
#
#    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# 


About GenomicDB:
----------------

The GenotypeGVCFs on whole genomes taking tremendous time and the GATK-GenotypeGVCFs[1] will be running in a single node.
The most efficient way to process the  GenotypeGVCFs is to run the GATK-combinegVCF to combine multiple GVCF files.
We used  GenomicsDB[2] to combine multiple GVCF files for GenotypeGVCF.
This GenotypeGVCFs is taking 4.5 days instead of 34 days for 3020 gVCFs file.

The GenomicDB is built on top of the TileDB system by the Intel Health and Life Science team.
The gVCF files are imported into GenomicDB [3] which required the following files:
        • vid_mapping_file: This is a JSON file contains Mapping contigs to disjoint column intervals, Mapping row id to samples/CallSets and Fields information.
        • loader_config_file: This is a JSON file, where the GenomicDB file is controlled for running on multiple nodes/cores.

We are generating the mapping and configuration files based on available number of cores to run the GenomicDB program.


About our Create_GenomicDB_config.sh BASH script:
--------------------------------------------------

The mapping and configuration files are generated using Create_GenomicDB_config.sh BASH script and the usage is as follows:

$ ./Create_GenomicDB_config.sh --help

  Usage:  Create_GenomicDB_config.sh <Options>

  This Create_GenomicDB_config.sh BASH script is used to generate the configuration files (CallSet.json and LoaderConfiguration.json) to run the GenomicDB application.

   Required parameter:
       - Create_GenomicDB_config.sh BASH script required No. of cores used for data-parallelization. Accordingly, the configuration files will be generated.

   By default, this BASH script detect:
       - the list of gVCF files in the current working directory.
       - generate the configuration files like CallSet.json and LoaderConfiguration.json in the current working directory.


   Alternatively, user can specify one or more following options:
     OPTIONS:
       -P | --project   Your project directory, where all the results will be created (by default, /gpfs/home/naga is used).
       -D | --directory  Your gVCF files directory, where all the gVCF files available (by default, /gpfs/home/naga is used).
       -R | --reference:  Your Reference file (by default, the GATK REFERENCE will be get it from gVCF files ).
       -N | --cores      No. of cores to be used for data-parallelization (Required).
       -h | --help       Display this help message


Different use cases:
---------------------

# Case 1:
---------

The gVCF files are automatically identified in the current working directory:

$ ./Create_GenomicDB_config.sh -N 32

Project Directory is ...  /gpfs/home/naga/MyProject_20170427_101357
Data Directory is .... /gpfs/home/naga
You are using 32 cores!
Processing the VCF files in /gpfs/home/naga directory


#Case 2:
--------

The gVCF file directory location is explicitly specified using –D option.
The reference is automatically identified from the gVCF file.

$  ./Create_GenomicDB_config.sh -N 32 -D /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/

Project Directory is ...  /gpfs/home/naga/MyProject_20170427_101502
Data Directory is .... /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/
You are using 32 cores!
Processing the VCF files in /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/ directory

adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003022_S4_L004.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003018_S5_L005.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003020_S3_L003.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0002954_S1_L001.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003017_S4_L004.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0002899_S6_L006.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003090_S8_L008.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0002926_S7_L007.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0002953_S8_L008.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003023_S1_L001.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0002878_S5_L005.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003016_S2_L002.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003078_S7_L007.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003025_S6_L006.hc.snps.indels.g.vcf.gz
adding: /gpfs/projects/NAGA/ramzi/GenomicsDB/final/best_practice/10-MD-15-0003096_S1_L001.hc.snps.indels.g.vcf.gz

15 Genome Samples are added !

 CallSet.json file was created and the file name is ...... /gpfs/home/naga/MyProject_20170427_101502/callset_20170427.json
 As per your gVCF.gz file, we are using this Reference file ....:  //gpfs/ngsdata/ref_data/Homo_sapiens/hs37d5/Sequences/BWAIndex/hs37d5.fa
 Vid Mapping file was created and it's available in ....: /gpfs/home/naga/MyProject_20170427_101502/template/vid_mapping_file.json

number of variant in file 3137454505

available cores : 32

 selected range : 98045453

Results are stored in /gpfs/home/naga/MyProject_20170427_101502/CONF



Running the GenomicDB:
======================

cd $PROJECT/CONF directory and execute the vcf2tiledb command.

ie.,

$ vcf2tiledb
Needs <loader_json_config_file>

Where, the loader_json_config_file are available in $PROJECT/CONF directory.

Hence,we can run multiple GenomicDB <loader_json_config_file> in the available number of cores.

$vcf2tiledb loader_config_file_20170427_32.json


This will generate COMBINE_Samples_20170427_32.vcf.gz file in your $PROJECT directory.



Reference:
1. https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_gatk_tools_walkers_variantutils_GenotypeGVCFs.php
2. https://github.com/Intel-HLS/GenomicsDB/wiki
3. https://github.com/Intel-HLS/GenomicsDB/wiki/Importing-VCF-data-into-GenomicsDB

