chapter = File.readlines "data/chp1.txt"

# chapter.map! {|line| delete_suffix!("\n") if line.size > 2 }
chapter = chapter.join.split("\n\n")
chapter.map! {|paragraph| "<p> #{paragraph} </p>"}

p chapter