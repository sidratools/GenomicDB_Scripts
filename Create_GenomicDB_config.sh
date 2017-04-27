#!/bin/bash
#
# --------------------------------------------------------------------------- #
# Copyright (c) 2016 SIDRA Medical and Research Center 
# Authors:
#             Ramzi Temanni <rtemanni@sidra.org>
#             Nagarajan Kathiresan <nkathiresan@sidra.org>
# --------------------------------------------------------------------------- #
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# --------------------------------------------------------------------------- #

## Create_GenomicDB_config.sh
## Version 0.4
 

### Generate_CallSet

function Generate_TileDB_Callset_from_gVCFs()
{
#  DATADIR=$1
#  SUMMARYFILE=$2
#echo $CALLSETFILE
#echo $DATADIR
flag=1;
  if [ -e $CALLSETFILE ]; then rm $CALLSETFILE; fi
  export linenum=0
  echo -e "{\n
                  \"callsets\" : { " >> $CALLSETFILE
                  for myngsfile in `find $DATADIR -name "*.vcf.gz"` ;
                  do
                        myfile=$(readlink -e $myngsfile);
                        base=$(basename "$myfile") ### | cut -f1 -d "_" ;
                        SampleID=$( echo "$base" | cut -f1 -d "." ) ;
                        ## myfile=$(readlink -e $myngsfile);
                        ## FileName=$(basename $myfile);
                        ## SampleID=$(echo $myfile | awk -F'/' '{print $7}' | awk -F'_' '{print $1} ');
                        ## FCID=$(echo $myfile | awk -F'/' '{print $6}');
                        ## echo -e " \"${SampleID}_${FCID}\" : { \n
                        echo -e " \"${SampleID}\" : { \n
                        \"row_idx\" : $linenum, \n
                        \"idx_in_file\": 0, \n
                        \"filename\": \"$myfile\" \n
                        }," >> $CALLSETFILE ;
                        echo "adding: $myngsfile";
			### Get the first VCF file to create vcf_header_filename.vcf and vid_mapping_file.json 
                        if [ $flag == 1 ];
  			 then
			  MyFile=$myngsfile;
 			  flag=0;
 			fi
                       let "linenum+=1";
                done
               sed -i '$ s/.$//' $CALLSETFILE
               echo -e "    } \n
        }" >> $CALLSETFILE
  sed -i '/^\s*$/d' $CALLSETFILE
       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
       echo -e "$linenum Genome Samples are added ! \n\n" ;
       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  export NUM_SAMPLES=$linenum ;
  echo -e "\n\n CallSet.json file was created and the file name is ...... $CALLSETFILE" ;

Generate_Header_and_Vid_Mapping ;
}

function Generate_Header_and_Vid_Mapping()
{
mkdir -p $PRJDIR/template;
rm -f $PRJDIR/template/template_vcf_header.vcf ;
zcat $MyFile | sed '/reference=file/q' | grep -v contig > $PRJDIR/template/template_vcf_header.vcf ; 

if [ $Ref_Set == 0 ] ;
then 
	tmp=`cat $PRJDIR/template/template_vcf_header.vcf | grep "reference=file" `
	Reference=${tmp#*/}
	echo -e "\n\n As per your gVCF.gz file, we are using this Reference file ....: " $Reference
else
	Reference=$REF;
	echo -e "\n\n As per your gVCF.gz file, we are using this Reference file ....: " $Reference
	
fi
zcat $MyFile | sed '/reference=file/q' | grep contig > $PRJDIR/template/tileDB_offset.txt ;

sed -e 's/##contig=<\(.*\)>/\1/' $PRJDIR/template/tileDB_offset.txt > $PRJDIR/template/tileDB_offset1.txt
cat $PRJDIR/template/tileDB_offset1.txt | grep -oP '(?<=ID=).+?(?=,length=)' > $PRJDIR/template/Chr.txt
cat $PRJDIR/template/tileDB_offset1.txt | awk -F ',length=' '{print $2}'> $PRJDIR/template/Pos.txt

lines=`cat $PRJDIR/template/Pos.txt | wc -l`
#echo $lines;

CMD="{\n
   \"fields\" : {                                                                              \n
   \t     \"PASS\":{\"type\":\"int\"},                                                              \n
   \t     \"LowQual\":{\"type\":\"int\" },                                                          \n
   \t  \"END\":{ \"vcf_field_class\":[\"INFO\"], \"type\":\"int\" },                                    \n
   \t    \"BaseQRankSum\":{ \"vcf_field_class\" : [\"INFO\"], \"type\":\"float\" },                     \n
   \t     \"ClippingRankSum\":{ \"vcf_field_class\" : [\"INFO\"], \"type\":\"float\" },                 \n
   \t     \"MQRankSum\":{ \"vcf_field_class\" : [\"INFO\"], \"type\":\"float\" },                       \n
   \t     \"ReadPosRankSum\":{ \"vcf_field_class\" : [\"INFO\"], \"type\":\"float\" },                  \n
   \t    \"MQ\":{ \"vcf_field_class\":[\"INFO\"], \"type\":\"float\" },                                 \n
   \t     \"RAW_MQ\":{ \"vcf_field_class\":[\"INFO\"], \"type\":\"float\" },                            \n
   \t     \"MQ0\":{ \"vcf_field_class\":[\"INFO\"], \"type\":\"int\" },                                 \n
   \t     \"DP\": { \"vcf_field_class\":[\"INFO\",\"FORMAT\"], \"type\":\"int\" },                        \n
   \t     \"GQ\": { \"vcf_field_class\":[\"FORMAT\"], \"type\":\"int\" },                               \n
   \t     \"MIN_DP\": { \"vcf_field_class\":[\"FORMAT\"], \"type\":\"int\" },                           \n
   \t     \"SB\":{ \"vcf_field_class\" : [\"FORMAT\"], \"type\":\"int\", \"length\":4 },                  \n
   \t     \"GT\": { \"vcf_field_class\":[\"FORMAT\"], \"type\":\"int\", \"length\":\"P\" },                 \n
   \t     \"AD\": { \"vcf_field_class\":[\"FORMAT\"], \"type\":\"int\", \"length\":\"R\" },                 \n
   \t     \"PGT\": { \"vcf_field_class\":[\"FORMAT\"], \"type\":\"char\", \"length\":\"VAR\" },             \n
   \t     \"PID\": { \"vcf_field_class\":[\"FORMAT\"], \"type\":\"char\", \"length\":\"VAR\" },             \n
   \t    \"PL\": { \"vcf_field_class\":[\"FORMAT\"], \"type\":\"int\", \"length\":\"G\" }                   \n
   \t         },                                                                              \n
         \"contigs\": {                                                                         "

echo -e $CMD  > $PRJDIR/template/vid_mapping_file.json


count=0;
var1=0;
paste $PRJDIR/template/Chr.txt $PRJDIR/template/Pos.txt | while IFS="$(printf '\t')" read -r f1 f2 ;
                        do
                           var1=$((var1+1))
#                          printf 'Chr: %s \t  Pos: %d \n' "$f1" "$count"
                           printf '\t"%s": { \n' "$f1"                                  >> $PRJDIR/template/vid_mapping_file.json
                           printf '\t\t "length" : %s, \n' "$f2"                        >> $PRJDIR/template/vid_mapping_file.json
                           printf '\t\t "tiledb_column_offset": %d \n' "$count"         >> $PRJDIR/template/vid_mapping_file.json
                           count=`expr $count + $f2`
                           if [ $lines -gt $var1 ];
                           then
                            printf '\t\t }, \n'                                          >> $PRJDIR/template/vid_mapping_file.json
                           else
                            printf '\t\t } \n'                                           >> $PRJDIR/template/vid_mapping_file.json
                            printf '\t } \n'                                             >> $PRJDIR/template/vid_mapping_file.json
                            printf ' } \n'                                               >> $PRJDIR/template/vid_mapping_file.json
                          fi
                        done

echo -e "\n\n Vid Mapping file was created and it's available in ....:" $PRJDIR/template/vid_mapping_file.json

}

############################################

function Generate_TileDB_Multi_config_from_gVCFs_multioutgvcf()
{
   PRJDIR=$1
   CONFFILE=$2
   OUTFILE=$3
   CALLSETFILE=$4

   export OUTDIR=$PRJDIR/VCF
   export CONFDIR=$PRJDIR/CONF
   mkdir -p $OUTDIR
   mkdir -p $CONFDIR


   let SPCP=$NUM_SAMPLES*35000

   if [ -e $CONFDIR ]; then rm -rf $CONFDIR; fi

   mkdir -p $OUTDIR
   mkdir -p $CONFDIR

   #GENOMESIZE=$(unpigz -p 16 -c $TEMPLATEVCF | wc -l)
   export GENOMESIZE=3137454505
   echo -e "\n\n number of variant in file $GENOMESIZE"

   #NUM_CORES=$(bhosts | awk '{if ($1 ~ /hpcgen/ && $2=="ok") print $4-$5}' | awk '{ sum+=$1} END {print sum}')
   echo -e "\n\n available cores : $NUM_CORES"
   WRANGE=$(printf "%.0f" $(echo "scale=2;$GENOMESIZE/${NUM_CORES}" | bc))
   echo -e "\n\n selected range : $WRANGE \n\n"

   #echo " selected config file: $CONFFILE"
   #echo " selected config file: $CONFFILE"

   export var=0

####
 #  for step in `seq 1 $WRANGE $GENOMESIZE` ;
 #   do
 #      let "endval =$step + ($WRANGE - 1)";
 #      let "var+=1";
       #echo $endval

step=1;
 for var in `seq 1 $NUM_CORES`;
 do
   endval=$(($WRANGE * $var))  
       CMD="{\n
                \"column_partitions\" : [{\"begin\": $step, \"end\": $endval, \"vcf_output_filename\": \"${OUTFILE}_${var}.vcf.gz\" }],
                \"callset_mapping_file\": \"$CALLSETFILE\",
                \"vcf_header_filename\": \"$PRJDIR/template/template_vcf_header.vcf\",
                \"vid_mapping_file\": \"$PRJDIR/template/vid_mapping_file.json\",
                \"reference_genome\": \"$Reference\",
                \"num_parallel_vcf_files\": 1,
                \"size_per_column_partition\": $SPCP,
                \"treat_deletions_as_intervals\": true,
                \"do_ping_pong_buffering\": true,
                \"offload_vcf_output_processing\": true,
                \"discard_vcf_index\": true,
                \"produce_combined_vcf\": true,
                \"vcf_output_format\": \"z\",
                \"compress_tiledb_array\" : true,
                \"segment_size\" : 100000000,
                \"num_cells_per_tile\" : 1000000,
                \"disable_synced_writes\": true
           }"
      # echo -e $CMD
    step=`expr $endval + 1`
    echo -e $CMD >> ${CONFDIR}/${CONFFILE}_${var}.json
  done
sed -i "s/ \"end\": ${endval},//g" ${CONFDIR}/${CONFFILE}_${var}.json
####
echo "Results are stored in $CONFDIR"

#Run_GenomicDB ;
}



function Run_GenomicDB()
{
for i in `seq 1 $var `; 
 do
   echo "Running $i ........:  		vcf2tiledb ${CONFDIR}/${CONFFILE}_${i}.json"
 done

}



function Validate_gVCF_is_Compressed()
{
  Go=0;
  TYPE1="";
  TYPE2="";
  if [ -d "$DATADIR" ]; then
    echo  "Processing the VCF files in $DATADIR directory" ;
    for File_Type in `find $DATADIR/. -type f -name '*.*' | sed 's|.*\.||' | sort -u ` ;
     do
       if [ "$File_Type" = "gz" ] ; then
         export TYPE1="gz" ;
         Go=1;
       elif [ "$File_Type" = "vcf" ]; then
         export TYPE2="vcf";
         Go=1;
       else
   	 echo  "" ;
       fi
    done
  else
    echo "Undefined Files are found!";
   exit;
 fi
#echo "Naga" $Go;
if [ $Go == 1 ]
then
  if [ "$TYPE1" = "gz" ]; then
	mkdir -p $PRJDIR
	export CALLSETFILE="$PRJDIR/callset_$(date +%Y%m%d).json"
	export CONFFILE="loader_config_file_$(date +%Y%m%d)"
        export OUTFILE="$PRJDIR/COMBINE_Samples_$(date +%Y%m%d)"
#        echo "Generate_TileDB_Callset_from_gVCFs $DATADIR $CALLSETFILE"
        Generate_TileDB_Callset_from_gVCFs $DATADIR $CALLSETFILE
#        echo "Generate_TileDB_Multi_config_from_gVCFs_multioutgvcf $PRJDIR $CONFFILE $OUTFILE $CALLSETFILE"
        Generate_TileDB_Multi_config_from_gVCFs_multioutgvcf $PRJDIR $CONFFILE $OUTFILE $CALLSETFILE
  else
   echo "VCF file(s) are not supported by GenomicDB ... Please compress the file in *.vcf.gz format";
   exit ;
 fi

else 
  echo "VCF files are not found in $DATADIR"
fi
}

function Help() 
{
cat <<-END

  Usage:  Create_GenomicDB_config.sh <Options>	

  This Create_GenomicDB_config.sh BASH script is used to generate the configuration files (CallSet.json and LoaderConfiguration.json) to run the GenomicDB application. 

   Required parameter:
       - Create_GenomicDB_config.sh BASH script required No. of cores used for data-parallelization. Accordingly, the configuration files will be generated.  

   By default, this BASH script detect:
       - the list of gVCF files in the current working directory.
       - generate the configuration files like CallSet.json and LoaderConfiguration.json in the current working directory.
      

   Alternatively, user can specify one or more following options: 
     OPTIONS:
       -P | --project			Your project directory, where all the results will be created (by default, $PWD is used).
       -D | --directory			Your gVCF files directory, where all the gVCF files available (by default, $PWD is used).
       -R | --reference			Your Reference file (by default, the GATK REFERENCE will be get it from gVCF files ).
       -N | --cores			No. of cores to be used for data-parallelization (Required). 
       -h | --help  			Display this help message

END
}

function Warning()
{
  printf "\033c"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  printf "\n\t\t\t\t\t Warning! ... Please run with minimum required parameter!! \n \t\t\t\t\t\t Example: CombineGVCFs.sh -N <No. of cores> \n\n" ;
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

}

function main()
{
   total="$#" ;
   if [ $total == 0 ]
   then
     Warning;
     exit;
  elif [ $total == 1 ] && ( [ $1 == "-h" ] || [ $1 == "--help" ] )
  then
    Help;
 else

 #  echo "Total argv = " $total
   Proj_Set=0 ;
   Data_Set=0 ;
   Cores_Set=0;
   Ref_Set=0; 
  for i in `seq 1 $total`
  do
     opt=${!i} ;
     case "$opt" in
        -P|--project)
		  Proj_Set=1;	          
	    	  tmp=$i;
                  tmp=$((tmp+1))
#	          echo $tmp "and " ${!tmp} ;
                  if [ $tmp -gt $total ] || [ ${!tmp} == "" ] || [ ${!tmp} == "-D" ] ;
                  then
		       printf "\033c"
                       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
                       echo -e " Specify the project directory location \n" ;
		       echo -e " Example: ./CombineGVCFs.sh -P /My_Project/Directory \n"
                       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
                       exit ;
                  else
                       #export PRJDIR="${!tmp}/MyProject_$(date +%Y%m%d%H:%M%S)" ;
 		       timestamp=`date +"%Y%m%d_%H%M%S"` ;	
                       echo "NAGA ......$$$$$ " $timestamp
		       export PRJDIR="${!tmp}/MyProject_$timestamp" ;
#                       echo -e "\n Project Directory is ... " $PRJDIR
                 fi
            ;;
        -D|--directory)
		  Data_Set=1;
		  tmp=$i;
                  tmp=$((tmp+1))
                  if [ $tmp -gt $total ] || [ ${!tmp} == "" ] || [ ${!tmp} == "-P" ];
                  then
		       printf "\033c"
                       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
                       echo -e " Specify the data directory location \n" ;
                       echo -e " Example: ./CombineGVCFs.sh -D /My_Data/Directory \n"
                       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
                       exit ;
                  else
                       export DATADIR=${!tmp} ;
#                       echo -e "\n Data Directory is ...." $DATADIR ;
                  fi
            ;;

        -R|--reference)
                  Ref_Set=1;
                  tmp=$i;
                  tmp=$((tmp+1))
                  if [ $tmp -gt $total ] || [ ${!tmp} == "" ] || [ ${!tmp} == "-R" ];
                  then
                       printf "\033c"
                       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
                       echo -e " Specify the Reference location \n" ;
                       echo -e " Example: ./CombineGVCFs.sh -R /gpfs/data_jrnas1/ref_data/Homo_sapiens/hs37d5/Sequences/BWAIndex/hs37d5.fa \n"
                       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
                       exit ;
                  else
                       export REF=${!tmp} ;
#                       echo -e "\n Data Directory is ...." $REF;
                  fi
            ;;

         -N|--cores)
		Cores_Set=1;
		tmp=$i;
                tmp=$((tmp+1))
                #if [ $tmp -gt $total ] || [ ${!tmp} == "" ] || [ ${!tmp} == "-D" ] || [ ${!tmp} == "-P" ] || [ !${!tmp} ]
                if [ ${!tmp} == "" ] || [ $tmp -gt $total ] 
                then
                       printf "\033c"
		       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -      
                       echo -e " Specify the No. of Cores \n" ;
                       echo -e " Example: ./CombineGVCFs.sh -N 32 \n"
                       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
                       exit ;
                 else
                        export NUM_CORES=${!tmp}
                  fi
            ;;
          -h|--help)
		Warning;
		help ;
	   ;;
     esac
  done

#echo "Debug" $Cores_Set $Data_Set $Proj_Set

if [ $Proj_Set == 0 ] && [ $Data_Set == 0 ]
then
    export PRJDIR="${PWD}/MyProject_$(date +%Y%m%d_%H%M%S)" ;
    export DATADIR=${PWD} ;
elif [ $Proj_Set == 0 ] 
then
     export PRJDIR="${PWD}/MyProject_$(date +%Y%m%d_%H%M%S)" ;
elif [ $Data_Set == 0 ]
then
     export DATADIR=${PWD} ;
elif [ $Cores_Set == 0 ]
then
    export NUM_CORES=1;
else
     echo ""
fi
       printf "\033c"
       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	 echo "Project Directory is ... " $PRJDIR ;
         echo "Data Directory is ...." $DATADIR ;
         echo "You are using" $NUM_CORES "cores!" ;
       printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
#       Validate_gVCF_is_Compressed;
	mkdir -p $PRJDIR
	export CALLSETFILE="$PRJDIR/callset_$(date +%Y%m%d).json"
	export CONFFILE="loader_config_file_$(date +%Y%m%d)"
        export OUTFILE="$PRJDIR/COMBINE_Samples_$(date +%Y%m%d)"
        echo "Generate_TileDB_Callset_from_gVCFs $DATADIR $CALLSETFILE"
        Generate_TileDB_Callset_from_gVCFs $DATADIR $CALLSETFILE
        echo "Generate_TileDB_Multi_config_from_gVCFs_multioutgvcf $PRJDIR $CONFFILE $OUTFILE $CALLSETFILE"
        Generate_TileDB_Multi_config_from_gVCFs_multioutgvcf $PRJDIR $CONFFILE $OUTFILE $CALLSETFILE
fi
}

main "$@"
