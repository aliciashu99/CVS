package com.company;

import java.lang.Object;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Random;

public class Main {

    public static void main(String[] args) {
	// write your code here
        //DataOutputStream out = null;
        PrintWriter out = null;
        int numOfRows = 100000; //Integer.getInteger(args[1]);
        //String outName = args[2];

        try {
           // out = new DataOutputStream(new BufferedOutputStream(new FileOutputStream("cvs_sample.txt")));
            out = new PrintWriter("pharmacy_claim.csv");

            out.println("prescription_id,fill_date,customer_id,store_id,description,create_date,update_date");
       //     System.out.printf("prescription_id,fill_date,customer_id,store_id,description,create_date,update_date\n");
            int count = 1;
            for (int i = 0; i < numOfRows; i++) {
                int prescription_id = count++;
         //       System.out.print(prescription_id + ",");
                out.write(Integer.toString(prescription_id));
                out.write(",");
           /*     fill_date: Random date between 2016-11-01 to 2016-11-30
                customer_id:  Random number between 1 & 1000 (duplicates ok)
                store_id: Random number between 1 & 100 (duplicates ok)
                description: Version 1.0
                create_date & update_date: Today date. */
                String fill_date = getRandomDate(305, 335, false);
          //      System.out.print(fill_date + ",");
                out.write(fill_date + ",");
                int customer_id = getRandomNumberInRange(1, 1000);
                out.write(Integer.toString(customer_id));
                out.write(",");
          //      System.out.print(customer_id + ",");
                int store_id = getRandomNumberInRange(1, 100);
                out.write(Integer.toString(store_id));
                out.write(",");
          //      System.out.print(store_id + ",");
                out.write("Version 1.0,");
          //      System.out.print("Version 1.0,");
                Calendar today = Calendar.getInstance();
          //      today.set(Calendar.DAY_OF_MONTH, 0); // same for minutes and seconds
                String create_date = new SimpleDateFormat("yyyy-MM-dd").format(today.getTime());
                out.write(create_date + ",");
                out.println(create_date);
         //       System.out.printf(create_date + "," + create_date);
            }
            out.flush();
            out.close();
        } catch (Exception e) {
        } finally
        {
        }

    }

    private static int getRandomNumberInRange(int min, int max) {

        if (min >= max) {
            throw new IllegalArgumentException("max must be greater than min");
        }

        Random r = new Random();
        return r.nextInt((max - min) + 1) + min;
    }

    private static String getRandomDate(int min, int max, boolean isDate) {

        GregorianCalendar gc = new GregorianCalendar();

        int year = randBetween(2016, 2016);

        gc.set(gc.YEAR, year);

      //  int dayOfYear = randBetween(1, gc.getActualMaximum(gc.DAY_OF_YEAR));
        int dayOfYear = randBetween(min, max);

        gc.set(gc.DAY_OF_YEAR, dayOfYear);

        String gDate = null;
        if (isDate) {
            gDate = gc.get(gc.YEAR) + "-" + (gc.get(gc.MONTH) + 1) + "-" + gc.get(gc.DAY_OF_MONTH);
        }
        else {
            String mm = null, dom = null;
            int month = gc.get(gc.MONTH) + 1;
            if (month < 10)
                mm = "0" + month;
            else
                mm = String.valueOf(month);
            int day = gc.get(gc.DAY_OF_MONTH);
            if (day < 10)
                dom = "0" + day;
            else
                dom = String.valueOf(day);
            gDate = gc.get(gc.YEAR) + mm + dom;
        }

        return gDate;
    }

    public static int randBetween(int start, int end) {
        return start + (int)Math.round(Math.random() * (end - start));
    }
}
