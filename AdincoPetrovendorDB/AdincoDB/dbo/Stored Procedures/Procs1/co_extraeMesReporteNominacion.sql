-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/02/2018
-- Description:	Extrae meses
-- =============================================
CREATE PROCEDURE [dbo].[co_extraeMesReporteNominacion]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET LANGUAGE Spanish;

	  SELECT 
	 CONCAT(Dia, ' ',
		datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha,
		CAST(C.IdFecha AS DATE) AS IdFecha
         FROM AP_Calendario C
         WHERE C.Dia = 1 and c.anio>=Year(GetDate())-1
END

