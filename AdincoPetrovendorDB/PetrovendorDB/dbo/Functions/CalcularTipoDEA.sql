-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[CalcularTipoDEA]-- '2020-02-21 17:31:19','2020-03-02 10:59:56'
(
	-- Add the parameters for the function here
	@FechaInicio DATETIME,
	@FechaFin DATETIME
)
RETURNS NVARCHAR(100) 
AS
BEGIN
	-- Declare the return variable here
	DECLARE @DIASDEA NVARCHAR(100);
	DECLARE @HORAS INT;
	DECLARE @HORASDIAS INT;
	DECLARE @DIAS INT;
	DECLARE @HORASFRACCION DECIMAL(5,2); 
	DECLARE @DIASFRACCIONDEA DECIMAL(5,2);

	SET @DIAS = ISNULL(DATEDIFF(DAY,@FechaInicio,@FechaFin),0);
	SET @HORASDIAS = (@DIAS * 24);
	SET @HORAS = ISNULL(DATEDIFF(HOUR,@FechaInicio,@FechaFin),0);
	SET @HORAS = (@HORAS - @HORASDIAS);
	SET @HORASFRACCION = ((CONVERT(DECIMAL(5,2),@HORAS)) / 24);

	SET @DIASFRACCIONDEA = ((CONVERT(DECIMAL(5,2),@DIAS)) + ISNULL(@HORASFRACCION,0.0));

	SET @DIASDEA = (CONVERT(NVARCHAR(100),CONVERT(DECIMAL(5,2),@DIASFRACCIONDEA)));
 
	-- Return the result of the function
	RETURN ISNULL(@DIASDEA,'0.0')

END
