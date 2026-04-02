package stubs;
import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;


//The data belonging to the same partition go to the same reducer. In a particular partition.
     
    // the type parameters are the input keys type, the input values type, the
    // output keys type, the output values type
 
  public class PartitionReducer extends Reducer<Text, Text, Text, LongWritable> {
 
        @Override
        public void reduce(Text key, Iterable<Text> values, Context context)
                throws IOException, InterruptedException {
 
        	// TODO:
           
            
        }
    }

