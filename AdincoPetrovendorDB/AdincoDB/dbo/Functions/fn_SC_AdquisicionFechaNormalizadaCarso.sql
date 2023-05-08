CREATE FUNCTION [dbo].[fn_SC_AdquisicionFechaNormalizadaCarso]  
(
    @Fecha NVARCHAR(MAX) )
 RETURNS VARCHAR(max)
AS  
BEGIN  
	DECLARE @Retorno NVARCHAR(MAX)
	DECLARE @FechaR VARCHAR(MAX) = NULL 
	    --FORMATO A RECIBIR DD/MM/YYYY PASAR A FORMATO YYYY/MM/DD
		SELECT	@Retorno =(SELECT  
							CONCAT(SUBSTRING(@Fecha, 7, 4), --> ANIO
							'-',
							SUBSTRING(@Fecha, 4,2),--> MES
							'-',
							SUBSTRING(@Fecha, 1, 2)--> DIA
							))

		DECLARE @EsFecha INT =(SELECT  ISDATE(@Retorno))
		IF @EsFecha = 1
			SET @FechaR= CAST(CONVERT(DATE, @Retorno) AS VARCHAR)
		ELSE 
			SELECT @FechaR=NULL 

		RETURN @FechaR
END  




