USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'fnCustomPass'
)
    DROP FUNCTION fnCustomPass;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnCustomPass] 
(    
    @size AS INT, --Tama�o de la cadena aleatoria
    @op AS VARCHAR(2) --Opci�n para letras(ABC..), numeros(123...) o ambos.
)
RETURNS VARCHAR(62)
AS
BEGIN    

    DECLARE @chars AS VARCHAR(52),
            @numbers AS VARCHAR(10),
            @strChars AS VARCHAR(62),        
            @strPass AS VARCHAR(62),
            @index AS INT,
            @cont AS INT

    SET @strPass = ''
    SET @strChars = ''    
    SET @chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    SET @numbers = '0123456789'

    SET @strChars = CASE @op WHEN 'C' THEN @chars --Letras
                        WHEN 'N' THEN @numbers --N�meros
                        WHEN 'CN' THEN @chars + @numbers --Ambos (Letras y N�meros)
                        ELSE '------'
                    END

    SET @cont = 0
    WHILE @cont < @size
    BEGIN
        SET @index = ceiling( ( SELECT rnd FROM vwRandom ) * (len(@strChars)))--Uso de la vista para el Rand() y no generar error.
        SET @strPass = @strPass + substring(@strChars, @index, 1)
        SET @cont = @cont + 1
    END    
        
    RETURN @strPass

END
GO


