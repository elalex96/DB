USE [Adinco]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ent_RutaArchivo_CF]    Script Date: 29/06/2022 05:27:07 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[fn_ent_RutaArchivo_CF] 
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

	DECLARE @Carpetas_Alias AS TABLE
        (
            carpeta  varchar(max),
            Id INT identity(1,1)
        );

	 insert into @Carpetas(carpeta)
	 SELECT * 
	 FROM [dbo].[fnSplitString] (
	 @string
	 ,'/')

	 INSERT INTO @Carpetas_Alias(carpeta)
	 SELECT 
			CASE
				WHEN CHARINDEX('- (',carpeta,1) > 0 THEN SUBSTRING((SUBSTRING(carpeta,CHARINDEX('- (',carpeta,1)+3,30)),1,(len(SUBSTRING(carpeta,CHARINDEX('- (',carpeta,2)+3,30)) - 1))
				WHEN CHARINDEX('.',carpeta,1) > 0 THEN carpeta
				ELSE substring(LTRIM(RTRIM(carpeta)),0,20)
			END
	 FROM @Carpetas

	 select @total = COUNT(1) from @Carpetas_Alias

	 SET @result = (SELECT  STUFF (
				(	SELECT		CASE WHEN @total = Id THEN '/'  + carpeta ELSE '/'  + substring(RTRIM(LTRIM(carpeta)),0,@sizeCarpeta) END 
					FROM	@Carpetas_Alias AS CF					
					
					FOR XML PATH ( '' )), 1, 1, '' ) )		

	
    RETURN @result
END 


