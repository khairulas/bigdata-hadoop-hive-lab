package stubs;

import java.io.IOException;

import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * To define a reduce function for your MapReduce job, subclass the Reducer
 * class and override the reduce method. The class definition requires four
 * parameters:
 * 
 * @param The
 *            data type of the input key - Text
 * @param The
 *            data type of the input value - IntWritable
 * @param The
 *            data type of the output key - Text
 * @param The
 *            data type of the output value - DoubleWritable
 */
public class KeyValueReducer extends Reducer<Text, Text, Text, DoubleWritable> {

	/**
	 * The reduce method runs once for each key received from the shuffle and
	 * sort phase of the MapReduce framework. The method receives:
	 * 
	 * @param A
	 *            key of type Text
	 * @param A
	 *            set of values of type IntWritable
	 * @param A
	 *            Context object
	 */
	@Override
	public void reduce(Text key, Iterable<Text> values, Context context)
			throws IOException, InterruptedException {

		/*
		 *TODO: write implementation for reducer.
		 */

	}
}