#!/bin/bash

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
    -sd|--sourcedir)
    SOURCEDIR="$2"
    shift # past argument
    ;;
    -dd|--destinationdir)
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
echo SOURCE DB  = "${SOURCEDB}"
echo TABLE      = "${TABLE}"
echo DESTINATION DB = "${DESTDB}"
echo SOURCE DIR = "${SOURCEDIR}"
echo DESTINATION DIR = "${DESTDIR}"
echo RUN = "${RUN}"
if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $1
fi

if [[(-z "$SOURCEDIR") && (-n "$DESTDIR")]]; then
    echo "Did not specify source directory";
    exit 1;
elif [[(-n "$SOURCEDIR") && (-z "$DESTDIR")]]; then
    echo "Did not specifiy destination directory, use source directory";
fi

if [[(-z "$DESTDB")]]; then
    echo "Did not provide destination database. Will use source database";
    DESTDB=$SOURCEDB;
    echo DESTDB $DESTDB;
fi

if [[(-z "$TABLE")]]; then
    echo "Run the script for all the tables";
    showtbl=$(hive -e "USE $SOURCEDB; SHOW tables");
    echo showtbl = $showtbl;
    echo "${showtbl}" > show.txt;
else
    showtbl=$TABLE
    echo "Run script for single table ${TABLE}";
fi

quote=\`
for table in ${showtbl};
do
    hive -e "SHOW CREATE TABLE $SOURCEDB.$table" > $table.txt
    sed -i "s/$quote$SOURCEDB.$table/$quote$DESTDB.$table/g" $table.txt;
    if [[(-n "$DESTDIR")]]; then
        echo "Replace source dir with destination dir";
        sed -i "s/$SOURCEDIR/$DESTDIR/g" $table.txt;
    fi
    if "$RUN"; then
        echo "Run CREATE EXTENAL TABLE command in destination database";
        hive -f $table.txt;
    fi
done

