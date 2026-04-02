package solution;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Partitioner;

//PopulationPartitioner is a custom Partitioner to partition the data according to Population.
  //The Population is a part of the value from the input file.
  //The data is partitioned based on the range of the Population.
  //In this example, there are 3 partitions, the first partition contains the information where the Population is less than 20
  //The second partition contains data with Population ranging between 20 and 50 and the third partition contains data where the age is >50.
  public class PopulationPartitioner extends Partitioner<Text, LongWritable> {

      @Override
      public int getPartition(Text key, LongWritable value, int numReduceTasks) {
    	  
    	  
          String country = key.toString();
          int charPosition = country.charAt(0)-65;

          //if the age is <20, assign partition 0
          if(charPosition >=0 && charPosition <10 ){               
              return 0 % numReduceTasks;
          }
          else if(charPosition >=10 && charPosition <20 ){               
              return 1 % numReduceTasks;
          }
          else              
              return 2 % numReduceTasks;
      
         
      }
  }
