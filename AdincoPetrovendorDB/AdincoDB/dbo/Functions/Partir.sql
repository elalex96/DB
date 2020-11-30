-- =============================================
-- Author:		Manuel CD
-- Create date: 29-10-17
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[Partir]
(
    @Texto VARCHAR(MAX),
    @Delimitador CHAR(1)
)
RETURNS @output TABLE(Datos VARCHAR(MAX)
)
BEGIN
    DECLARE @Empieza INT, @Termina INT
    SELECT @Empieza = 1, @Termina= CHARINDEX(@Delimitador , @Texto )
    WHILE @Empieza < LEN(@Texto ) + 1 BEGIN
        IF @Termina = 0  
            SET @Termina = LEN(@Texto ) + 1
      
        INSERT INTO @output (Datos)  
        VALUES(SUBSTRING(@Texto , @Empieza , @Termina - @Empieza ))
        SET @Empieza = @Termina + 1
        SET @Termina = CHARINDEX(@Delimitador , @Texto , @Empieza )
        
    END
    RETURN
END