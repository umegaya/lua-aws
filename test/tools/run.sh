#!/bin/bash

# decide which lua variant to use
LUA=`which luajit`
if [ $? -ne 0 ]; then
	LUA=`which lua`
fi

set +e
RESULT=0
echo "==== run test $1 ===="
if [ ! -z $2 ]; then
	# run with mock
	# check this uses aws service endpoint
	DIRNAME=`dirname $1`
	DIR=${DIRNAME#./test}
	if [ ! -z $DIR ]; then
		# non-top-level test does not use endpoint
		$LUA $1
		RESULT=$?
	else
		# inject service name which use with mock
		SERVICE=`basename $1 .lua`
		# run moto_server with service name
		moto_server $SERVICE &
		PID=$!
		if [ -z $PID ]; then
			echo "cannot get pid"
			exit 1
		fi
		echo "running mock server at $PID"
		sleep 2
		# run test with using mock
		$LUA $1 http://127.0.0.1:5000
		RESULT=$?
		# shutdown moto server
		kill $PID
	fi
else
	# normal run
	$LUA $1
	RESULT=$?
fi
echo "==== test $1 result $RESULT ===="
exit $RESULT
