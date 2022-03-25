USE [Adinco]
GO
IF object_id('fn_ent_RutaArchivo', 'FN') IS NOT NULL
BEGIN
   DROP FUNCTION [dbo].[fn_ent_RutaArchivo]
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplitString]    Script Date: 25/03/2022 01:50:08 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_ent_RutaArchivo] 
( 
    @string NVARCHAR(MAX), 
    @sizeCarpeta INT
) 
RETURNS varchar(max)
 
 BEGIN 
     declare @result varchar(max)
	  declare @count int,@total int 

	DECLARE @Carpetas AS TABLE
        (
            carpeta  varchar(max),
            Id INT identity(1,1)
        );

	 insert into @Carpetas(carpeta)
	 SELECT * 
	 FROM [dbo].[fnSplitString] (
	 @string
	 ,'/')

	 select @total = COUNT(1) from @Carpetas

	 SET @result = (SELECT  STUFF (
				(	SELECT		CASE WHEN @total = Id THEN '/'  + carpeta ELSE '/'  + substring(RTRIM(LTRIM(carpeta)),0,@sizeCarpeta) END 
					FROM	@Carpetas AS CF					
					
					FOR XML PATH ( '' )), 1, 1, '' ) )		

	
    RETURN @result
END 


