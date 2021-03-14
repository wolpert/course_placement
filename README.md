# course_placement
Quick program to place students in courses

## Purpose

This is a small program to try to simply place students in a one of many courses.
Input is a csv file where the first line contains course names with their capacity,
and each line after that is the student with a 1 in the column if they want to be
in that course.

## Usage

Execute ```ruby priority.rb testfile.csv```

This will run the program trying to make sure the largest classes are processed
first. If you want to run with the smallest processed first, use this:

```run priority -small testfile.csv```

## Incomplete

Do not use this as a good example of a ruby program please... it was writen fairly
quickly to solve a placement problem. If this gets used more, I'll refactor so its
reasonable.

Uses a simply priority algo to solve. However, optimal student placement isn't
done yet. So you can run it multiple times to try to reduce the students left
over. I'll get around to optimize the placement...

Sample usage: (Test file test1.csv results in one leftover student)

```
(main|…5) % ruby ./priority.rb test1.csv
Courses {"c1"=>2, "c2"=>2, "c3"=>3, "c4"=>1}
courses_capacity_order ["c3", "c1", "c2", "c4"]
Dups: []
Left over students {"f"=>["c1", "c3"]}
Left over courses {}
Courses under capacity {}
Wrote results to placement.csv
Wrote left overs to leftovers.csv
Wrote undercapacity to undercapacity.csv
```

## License

Apache License 2.0. Do as thou wilt...