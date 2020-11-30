-- =============================================
-- Author:		Reyna Olvera 
-- Create date: 21/02/18
-- Description:	Checa si ya esta el reporte insertado para insertar con nuevas modificaciones
-- =============================================
CREATE PROCEDURE [dbo].[sp_co_ModificaReporteCruceProduccion]
	-- Add the parameters for the stored procedure here
@idContrato int=0,
@fecha nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Delete from PC_CruceProduccionVentas 
	where FechaReporte=@fecha and idContrato=@idContrato
	
	
END

