#!/bin/bash

usage ()
{
  echo ' '
  echo 'The script will not move any data. Users will run it after the data has been moved to new locations.'
  echo 'The script will save Hive Create External Table commands for all the tables in a file output.txt.'
  echo 'Users should view this file and make sure the commands are correct before running the commands.'
  echo 'Note: if the source directory containing hdfs path and destination directory is specified, '
  echo 'the script will remove the hdfs header and leave the directory starting with (/).'
  echo 'For example, if the source directory LOCATION is specified as /foo in hdfs:'
  echo 'hdfs://ip-172.ec2.internal:8020/foo/bardb/87fc6c5ae4b0d549be24323e/merged/orc'
  echo 'and the destination is specified as /bar, the new hdfs destination LOCATION becomes:'
  echo '/bar/bardb/87fc6c5ae4b0d549be24323e/merged/orc'
  echo ' '
  echo 'Usage : ./iw_move_tables.sh'
  echo '-s|--sourcedb <Hive DB name> '
  echo '-t|--table <Optional: Hive table name. If not specified use ALL> '
  echo '-d|--destinationdb <Optional. If not specified use source db name>'
  echo '-i|--sourcedir <Directory where tables are located>' 
  echo '-o|--destinationdir <Directory where tables are located after the move>'
  echo '-r|--run <Optional. Run script> true (Default: false)'
  exit
}

if [ "$#" -le 1 ]
then
  usage
fi

RUN=false
while [[ $# -gt 1 ]]
do
  key="$1"

  case $key in
    -s|--sourcedb)
      SOURCEDB="$2"
      shift # past argument
      ;;
    -t|--table)
      TABLE="$2"
      shift # past argument
      ;;
    -d|--destinationdb)
      DESTDB="$2"
      shift # past argument
      ;;
    -i|--sourcedir)
      SOURCEDIR="$2"
      shift # past argument
      ;;
    -o|--destinationdir)
      DESTDIR="$2"
      ;;
    -r|--run)
      RUN="$2"
      shift # past argument
      ;;
    *)
      # unknown option
      ;;
  esac
  shift # past argument or value
done

if [[(-z "$SOURCEDB")]]; then
  echo "Did not provide source database.";
  exit 1;
fi
echo SOURCE DB       = "${SOURCEDB}"
echo TABLE           = "${TABLE}"
echo DESTINATION DB  = "${DESTDB}"
echo SOURCE DIR      = "${SOURCEDIR}"
echo DESTINATION DIR = "${DESTDIR}"
echo RUN             = "${RUN}"

if [[(-z "$SOURCEDIR") && (-n "$DESTDIR")]]; then
  echo "Did not specify source directory";
  exit 1;
elif [[(-n "$SOURCEDIR") && (-z "$DESTDIR")]]; then
  echo "Did not specifiy destination directory, Will use source directory";
fi

if [[(-z "$DESTDB")]]; then
  echo "Did not provide destination database. Will use source database";
  DESTDB=$SOURCEDB;
  echo DESTDB $DESTDB;
fi

if [[(-z "$TABLE")]]; then
  echo "Running the script for all the tables";
  showtbl=$(hive -e "USE $SOURCEDB; SHOW tables");
  echo showtbl = $showtbl;
  echo "${showtbl}" > show.txt;
else
  echo "Running the script for single table ${TABLE}";
  showtbl=$TABLE
fi

rm output.txt
quote=\`
for table in ${showtbl};
do
  hive -e "SHOW CREATE TABLE $SOURCEDB.$table" >> output.txt
  sed -i "s/$quote$SOURCEDB.$table/$quote$DESTDB.$table/g" output.txt;
  if [[(-n "$DESTDIR")]]; then
    echo "Replace source dir with destination dir";
    if grep -q "hdfs" output.txt; then
      ddir=$(grep "hdfs" output.txt)
      ddir=$(echo $ddir | sed -e 's/^[ \t]*//')
      pos=$(echo $ddir | grep -aob '://'| grep -oE '[0-9]+')
      pos=$(($pos+3))
      ddir=$(echo ${ddir:$pos})
      pos=$(echo $ddir | grep -aob '/'| grep -oE '[0-9]+')
      newpos=$(echo $pos | awk '{print $1}')
      echo ${ddir:$newpos} > tmp.txt
      sed -i "s%$SOURCEDIR%$DESTDIR%g" tmp.txt
      sed -i "s/^/'/" tmp.txt
      substitute=$(cat tmp.txt)
      sed -i "/hdfs/c $substitute" output.txt
    else
      sed -i "s%$SOURCEDIR%$DESTDIR%g" output.txt
    fi
  fi
  echo ";" >> output.txt
done
cat output.txt
if "$RUN"; then
  echo "Running generated CREATE EXTENAL TABLE commands in destination database";
  hive -f output.txt;
fi

