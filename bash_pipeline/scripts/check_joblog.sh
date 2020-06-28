#! /bin/bash
joblog=$1
message=$2

  # Parse parallel joblog to find nonzero exit codes
  jobswitherrors=`tail -n +2 $joblog |
                  awk -F'\t' '$7 != 0' |
                  awk -F' ' '{print $NF}'`

  if [ -n "$jobswitherrors" ];then
    echo -e "\e[91m$message\e[39m"
    echo -e "\e[91mSee error logs at:\e[39m"
    echo -e `echo $jobswitherrors | sed 's/ /\r/g'`
    exit 1
  fi
