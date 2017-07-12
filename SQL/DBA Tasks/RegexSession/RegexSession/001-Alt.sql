
/*
REGEX isn't right for everything.  Sometimes you can
get some pretty good search/replace through normal
methods, or even just some nice editing using SSMS
features.

Here you can use Alt+left-click and highlight vertically.
Then you can just type the replacement text you want
on all lines at once.  
We're going to change the schema from dbo to [MySchema].
Then we can highlight the "." and change it to ".["

The problem is that we can't finish off the line as
a group like that.  This is where regex comes into play.

A regular expression is a special text string for describing a search pattern

So you'll use it many times when you want to do something
against certain text patterns in the entire script.
So adding something to the beginning of each line, or
maybe at the end of each line, or on each iteration of
a text combo... something like that.

*/

SELECT * FROM dbo.T1
SELECT * FROM dbo.T2
SELECT * FROM dbo.T3
SELECT * FROM dbo.T3
SELECT * FROM dbo.T4
SELECT * FROM dbo.T5
SELECT * FROM dbo.T6
SELECT * FROM dbo.T7
SELECT * FROM dbo.T8
SELECT * FROM dbo.T9
SELECT * FROM dbo.T10
SELECT * FROM dbo.T11