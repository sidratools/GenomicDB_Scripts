GenomicDB_Scripts
Generate the configuration files (CallSet.json and LoaderConfiguration.json) to run the GenomicDB application


 Copyright (c) 2017 SIDRA Medical and Research Center, Biomedical Informatics, Doha, Qatar
 Authors:
             
             Ramzi Temanni <rtemanni@sidra.org>
             
             Nagarajan Kathiresan <nkathiresan@sidra.org>

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

 


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

Reference:
---------
1. https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_gatk_tools_walkers_variantutils_GenotypeGVCFs.php
2. https://github.com/Intel-HLS/GenomicsDB/wiki
3. https://github.com/Intel-HLS/GenomicsDB/wiki/Importing-VCF-data-into-GenomicsDB
