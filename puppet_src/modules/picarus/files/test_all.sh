set -e

# HBase
cd /root/src/hadoopy-hbase/tests
python thrift_example.py
python hbase_test.py

# Hadoopy Tests
cd /root/src/hadoopy/tests
python test_with_hadoop.py