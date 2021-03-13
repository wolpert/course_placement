raise "No csv given" unless ARGV.length>0

filename=ARGV[0]

# Reading the CSV without relying on a CSV extension.
# Assumes first row is course names.
capacity=nil
students={}
lookup=[]

# Assumes each entry past the first col is course number. Warning, lookup is modified.
def process_course(line,lookup)
    hash={}
    line.split(",").drop(1).each do |course_capacity|
       course,capacity = course_capacity.strip.split(":")
       hash[course] = capacity.to_i
       lookup << course # so the student line looks up the course
    end
    return hash
end

IO.foreach(filename) do |line|
    if capacity
        student=nil
        priority=[]
        list=line.split(",")
        list.each_index do |idx|
            if student
                priority<<lookup[idx-1] if list[idx].strip == "1"
            else
                student=list[idx]
            end
        end
        students[student]=priority
    else # No courses yet, must be first line
        capacity = process_course(line,lookup)
    end
end
puts "Courses #{capacity}"
#puts "Students #{students}"

# By here, we have list of courses with their capacity, and list of students with selected courses.
# Now, for each course, create a list of students.
courses_selected=Hash.new{|hash,key|hash[key] = []}
students.each do |student,list|
    list.each{|course|courses_selected[course]<<student}
end

# Prints out courses per student via their priority...
#puts "courses_selected #{courses_selected}"

# Create a course capacity list from decreasing class size.
courses_capacity_order = capacity.keys.sort{|a,b| capacity[b] <=> capacity[a]}
puts "courses_capacity_order #{courses_capacity_order}"


# Okay, we need to process the courses_selected list. For each course in courses_selected that is under capacity, in order of 
# courses_capacity_order, remove it from the lists (courses_capacity_order and courses_selected) and remove the students in the list
# from the other courses in the list. We have to iterate until there is no course left, or until there is no under capacity course.

def next_undercapacity_or_largest_course(courses_capacity_order, courses_selected, capacity)
    return nil unless courses_capacity_order
    courses_capacity_order.each do |course|
        if courses_selected[course].size <= capacity[course]
            return course
        end
    end
    # Okay, return largest course next.
    return courses_capacity_order[0]
end


def clear_student_from_course(course_students, students, courses_selected)
    course_students.each do |student|
        # Now, go to the courses for that student, and remove them from the other courses.
        students[student].each do |course|
            courses_selected[course].delete(student) if courses_selected.has_key?(course) # Course may have been deleted
        end
        # Remove the student...
        students.delete(student)
    end
end

# Returns the list of students ordered by those with the least remaining courses first
def get_students_with_least_available(course_students, students, course_size)
    # Shuffle first since many students have same number.
    order_list=course_students.shuffle.sort{|a,b| students[a].size <=> students[b].size} # increase course size
    return order_list[0, course_size]
end

master_list={}
undercapacity={}

course_to_process = next_undercapacity_or_largest_course(courses_capacity_order, courses_selected, capacity)
while (course_to_process!=nil)
    course_students=courses_selected.delete(course_to_process)
    course_size=capacity[course_to_process]
    undercapacity[course_to_process]= course_size - course_students.size if course_size > course_students.size
    #student_list = course_students.shuffle[0,course_size] # Get capacity for the course
    student_list = get_students_with_least_available(course_students, students, course_size)
    master_list[course_to_process] = student_list
    courses_capacity_order.delete(course_to_process)
    clear_student_from_course(student_list, students, courses_selected)
    course_to_process = next_undercapacity_or_largest_course(courses_capacity_order, courses_selected, capacity)
end

# HACK HACK HACK HACK
class Array
    def find_duplicates
      select.with_index do |e, i|
        i != self.index(e)
      end
    end
end

all_students = []
master_list.values.each{|s| all_students << s}
all_students << students.keys
all_students.flatten!

#puts "Result: #{master_list}"
puts "Left over students #{students}"
puts "Left over courses #{courses_selected}"
puts "Courses under capacity #{undercapacity}"
outfilename="placement.csv"
File.open(outfilename, "w") do |file|
    master_list.each{|course, students| file.puts "#{course},#{students.join(',')}"} 
end
puts "Wrote results to #{outfilename}"

outfilename="leftovers.csv"
File.open(outfilename, "w") do |file|
    students.each{|student, courses| file.puts "#{student},#{courses.join(',')}"} 
end
puts "Wrote left overs to #{outfilename}"

outfilename="undercapacity.csv"
File.open(outfilename, "w") do |file|
    undercapacity.each{|course, size| file.puts "#{course},#{size}"} 
end
puts "Wrote undercapacity to #{outfilename}"

puts "WARNING: Validation failed... " if (all_students.find_duplicates.size>0)