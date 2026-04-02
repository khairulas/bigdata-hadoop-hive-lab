package solution;
import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

//mapper output format : Country is the key, the value is formed by concatenating the Population
 
    // the type parameters are the input keys type, the input values type, the
    // output keys type, the output values type
  
    public class PartitionMapper extends
            Mapper<Object, Text, Text, LongWritable> {
 
       
        public void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {
 
            String[] tokens = value.toString().trim().split(",");
           
            if (tokens.length == 3){
                 context.write(new Text(tokens[0]), new LongWritable(Integer.parseInt(tokens[2].trim())));
             }      
            //the mapper emits key, value pair where the key is the Country
        }
    }

