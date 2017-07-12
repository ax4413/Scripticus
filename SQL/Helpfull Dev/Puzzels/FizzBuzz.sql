declare @counter int
declare @output varchar(15)

set @counter = 1

while @counter < 101
begin
    set @output =''

    if @counter % 3 = 0
    begin
	   set @output = 'Fizz'
    end

    if @counter % 5 = 0
    begin
	   set @output = @output + 'Buzz'
    end

    if @output =''
    begin
	   set @output = @counter
    end

    print @output

    set @counter = @counter + 1
end




Declare @number int;
declare @num int;

set @num=1;
set @number=100;

while(@num<@number)
begin
    if((@num%3)=0 and (@num%5)=0)
	   print 'fizzbuzz';
    else if((@num%3)=0)
	   print 'fizz'
    else if((@num%5)=0)
	   print 'buzz'
    else	   
	   print @num

    set @num=@num+1;
end