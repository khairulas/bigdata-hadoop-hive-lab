package stubs;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Partitioner;

//PopulationPartitioner is a custom Partitioner to partition the data according to Population.
  //The Population is a part of the value from the input file.
  //The data is partitioned based on the range of the Population.
  //In this example, there are 3 partitions, the first partition contains the information where the City is less than 10
  //The second partition contains data with Population ranging between 20 and 50 and the third partition contains data where the age is >50.
  public class PopulationPartitioner extends Partitioner<Text, Text> {

      @Override
      public int getPartition(Text key, Text value, int numReduceTasks) {
		
    	// TODO:
    	  return numReduceTasks;
      }
  }
