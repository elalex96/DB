-- =============================================
-- Author:		Oscar Mtz
-- Create date: 27/09/2017
-- Description:	Devuele la fecha calculada, en base a una fecha final de entrega proporcionado.
-- Funcion para agregar/restar los dias requeridos, omitiendo los dias Sabados y Domingos.
-- =============================================

--@FECHAFINAL Fecha final de entrega obtenido de parametro.
--@hora especificado para inicio/termino de la cita.
--@minuto especificado para inicio/termino de la cita.
--@segundo especificado para inicio/termino de la cita.
--@milisegunado especificado para inicio/termino de la cita.
--@numeroDias. representa el valor en dias a agregar/restar a la fecha final entrega.
--@ValorDia. Representa un valor 1 positivo o negativo (-1) si es que se desea restar los dias.
CREATE FUNCTION [dbo].[fn_AGREGADIASHABILES](	@FECHAFINAL AS DATE, 
											@hora AS INT, 
											@minuto AS INT, 
											@segundo AS INT, 
											@milisegunado AS INT, 
											@numeroDias AS INT, 
											@ValorDia AS INT)
RETURNS DATETIME
AS
BEGIN
DECLARE @FECHANUEVA AS DATETIME = @FECHAFINAL,
		@DIAS AS INT = @numeroDias;

    WHILE @DIAS>0
    BEGIN
       SET @FECHANUEVA=DATEADD(d,@ValorDia,@FECHANUEVA)
       IF DATENAME(DW,@FECHANUEVA)='saturday' SET @numeroDias = @numeroDias + 1; 
       IF DATENAME(DW,@FECHANUEVA)='sunday' SET @numeroDias = @numeroDias + 1;	   
       SET @DIAS=@DIAS-1
    END		  		
	
	SET @FECHAFINAL=DATEADD(d,(@numeroDias * @ValorDia),@FECHAFINAL)
	IF DATENAME(DW,@FECHAFINAL)='saturday' SET @FECHAFINAL = DATEADD(d,-1,@FECHAFINAL); 
	IF DATENAME(DW,@FECHAFINAL)='sunday' SET @FECHAFINAL = DATEADD(d,-2,@FECHAFINAL);

	--Agregar complemento Time.
	RETURN DATETIMEFROMPARTS (DATEPART(year, @FECHAFINAL), DATEPART(month, @FECHAFINAL), DATEPART(day, @FECHAFINAL), @hora, @minuto, @segundo, @milisegunado);	 				
	--RETURN CAST(@FECHAFINAL AS DATETIME)
END