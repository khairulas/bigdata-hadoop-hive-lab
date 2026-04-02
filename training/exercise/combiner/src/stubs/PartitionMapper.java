package stubs;
import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

//mapper output format : gender is the key, the value is formed by concatenating the name, age and the score
 
    // the type parameters are the input keys type, the input values type, the
    // output keys type, the output values type
  
    public class PartitionMapper extends
            Mapper<Object, Text, Text, LongWritable> {
 
       
        public void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {
 
        	// TODO:
        	
        }
    }

