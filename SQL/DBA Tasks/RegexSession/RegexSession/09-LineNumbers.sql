/*

Here you're removing numbers from code you got from the internet.
You want to account for different spaces after the numbers.
Search for: ^:z\.:b*
Replace with: nothing.

^ - line begins with.
:z - any integer.
\. - followed by a period, so it has to be escaped with the \
:b - any space or tab.
* - zero or more... so this means zero or more spaces or tabs.  this will cover any amount of tabs.
*/

1. SELECT * FROM myTable
2. SELECT * FROM myTable
3. SELECT * FROM myTable
4. SELECT * FROM myTable
10. SELECT * FROM myTable
111. SELECT * FROM myTable   
1231234. SELECT * FROM myTable