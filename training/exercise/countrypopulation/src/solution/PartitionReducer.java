package solution;
import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;


//The data belonging to the same partition go to the same reducer. In a particular partition, all the values with the same key are iterated and the person with the maximum score is found.
    //Therefore the output of the reducer will contain the male and female maximum scorers in each of the 3 age categories.
 
    // the type parameters are the input keys type, the input values type, the
    // output keys type, the output values type
 
  public class PartitionReducer extends Reducer<Text, LongWritable, Text, LongWritable> {
 
        @Override
        public void reduce(Text key, Iterable<LongWritable> values, Context context)
                throws IOException, InterruptedException {
 
         
           
            long population = 0;
            //iterating through the values corresponding to a particular key
            for(LongWritable val: values){
                      
                population += val.get();
                          
            }
            context.write(key, new LongWritable(population));
        }
    }

