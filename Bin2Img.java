import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.Writer;
import java.nio.charset.StandardCharsets;

public class Bin2Img
{
	private static String FILE_HEADER = "v2.0 raw";

	public static void main(String[] args)
	{
		if(args.length != 2)
		{
			System.out.println("USAGE: java Bin2Img <raw binary> <Logisim memory image>");
			System.exit(1);
		}

		File binFile = new File(args[0]);
		BufferedReader bin = null;
		try
		{
			bin = new BufferedReader(new InputStreamReader(new FileInputStream(binFile), StandardCharsets.ISO_8859_1));
		}
		catch(Exception ex)
		{
			System.err.println("FATAL: Cannot open input file '" + binFile + "'");
			System.exit(2);
		}

		File imgFile = new File(args[1]);
		BufferedWriter img = null;
		try
		{
			img = new BufferedWriter(new FileWriter(imgFile));
		}
		catch(Exception ex)
		{
			System.err.println("FATAL: Cannot open output file '" + imgFile + "'");
			System.exit(3);
		}

		write(String.format("%s\n", FILE_HEADER), img, imgFile);

		int bite = read(bin, binFile);
		while(bite != -1)
		{
			write(String.format("%02x\n", bite), img, imgFile);
			bite = read(bin, binFile);
		}

		try
		{
			img.close();
			bin.close();
		}
		catch(Exception ex)
		{
			System.err.println("WARN: Failed to close file, which may now be corrupt");
		}
	}

	private static int read(Reader in, File inFile)
	{
		try
		{
			int bite = in.read();
			return bite;
		}
		catch(Exception ex)
		{
			System.err.println("FATAL: Cannot read from input file '" + inFile + "'");
			System.exit(4);
			return -1; // We never get here.
		}
	}

	private static void write(String bytes, Writer out, File outFile)
	{
		try
		{
			for(int index = 0; index < bytes.length(); index++)
			{
				out.write(bytes.charAt(index));
			}
		}
		catch(Exception ex)
		{
			System.err.println("FATAL: Cannot write to output file '" + outFile + "'");
			System.exit(5);
		}
	}
}
