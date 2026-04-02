package solution;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

/* 
 * MapReduce jobs are typically implemented by using a driver class.
 * The purpose of a driver class is to set up the configuration for the
 * MapReduce job and to run the job.
 * Typical requirements for a driver class include configuring the input
 * and output data formats, configuring the map and reduce classes,
 * and specifying intermediate data formats.
 * 
 * The following is the code for the driver class:
 */
public class Driver {

	public static void main(String[] args) throws Exception {

		/*
		 * The expected command-line arguments are the paths containing input
		 * and output data. Terminate the job if the number of command-line
		 * arguments is not exactly 2.
		 */
		if (args.length != 2) {
			System.out.printf("Usage: Age Calculator <input dir> <output dir>\n");
			System.exit(-1);
		}

		/*
		 * Instantiate a Job object for your job's configuration.
		 */
		@SuppressWarnings("deprecation")
		Job job = new Job();

		/*
		 * Specify the jar file that contains your driver, mapper, and reducer.
		 * Hadoop will transfer this jar file to nodes in your cluster running
		 * mapper and reducer tasks.
		 */
		job.setJarByClass(PartitionReducer.class);

		/*
		 * Specify an easily-decipherable name for the job. This job name will
		 * appear in reports and logs.
		 */
		job.setJobName("PopulationChart");

		/*
		 * Specify the paths to the input and output data based on the
		 * command-line arguments.
		 */
		FileInputFormat.setInputPaths(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		/*
		 * Specify the mapper and reducer classes.
		 */
		job.setMapperClass(PartitionMapper.class);
		job.setReducerClass(PartitionReducer.class);
		job.setPartitionerClass(PopulationPartitioner.class);
		job.setNumReduceTasks(3);
		/*
		 
		 
		 * In text format files, each record is a line delineated by a by a line
		 * terminator.
		 * 
		 * When you use other input formats, you must call the
		 * SetInputFormatClass method. When you use other output formats, you
		 * must call the setOutputFormatClass method.
		 */

		/*
		 * have the same data types as the reducer's output keys and values:
		 * Text and LongWritable.
		 * 
		 * When they are not the same data types, you must call the
		 * setMapOutputKeyClass and setMapOutputValueClass methods.
		 */

		/*
		 * Specify the job's output key and value classes.
		 */
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(LongWritable.class);

		/*
		 * Start the MapReduce job and wait for it to finish. If it finishes
		 * successfully, return 0. If not, return 1.
		 */
		boolean success = job.waitForCompletion(true);
		System.exit(success ? 0 : 1);
	}
}
