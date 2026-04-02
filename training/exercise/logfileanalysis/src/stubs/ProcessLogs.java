package stubs;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class ProcessLogs {

	public static void main(String[] args) throws Exception {

		if (args.length != 2) {
			System.out.printf("Usage: ProcessLogs <input dir> <output dir>\n");
			System.exit(-1);
		}

		@SuppressWarnings("deprecation")
		Job job = new Job();
		job.setJarByClass(ProcessLogs.class);
		job.setJobName("Process Logs");

		FileInputFormat.setInputPaths(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		/*
		 * TODO implement
		 */

		boolean success = job.waitForCompletion(true);
		System.exit(success ? 0 : 1);
	}
}
