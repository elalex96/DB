-- =============================================
-- Author:		Reyna Olvera
-- Create date: 22/02/2018
-- Description:	Solo extrae el mes y año 
-- =============================================
CREATE PROCEDURE [dbo].[sp_Co_ExtraeMesAnioContrato]
	-- Add the parameters for the stored procedure here
@idContrato int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	      SET NOCOUNT ON;
         DECLARE @FechaEfectiva AS DATE;
         SET LANGUAGE spanish;
         SELECT @FechaEfectiva = InicioVigencia
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;
         SELECT CAST(C.IdFecha AS DATE) AS IdFecha,
                CONCAT(datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
         FROM AP_Calendario C
         WHERE C.Dia = 1
               AND C.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP
         ORDER BY c.IdFecha desc;
    -- Insert statements for procedure here


END
