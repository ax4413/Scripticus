Declare @c uniqueidentifier
while(1=1) begin
    select top 1 @c = conversation_handle from dbo.TrackingRequestQueue
    if (@@ROWCOUNT = 0)
        break
    end conversation @c with cleanup
end
 
-- The following SQL will report the progress of the above
 
SELECT COUNT(*)
FROM [dbo].[TrackingRequestQueue] WITH(NOLOCK)
