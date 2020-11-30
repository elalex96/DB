-- =============================================
-- Author:		Reyna Olevra
-- Create date: 20180824
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE sp_PR_ExtraeRegionFiscalPozo

	@idContrato INT,
	@idUsuario INT
AS
BEGIN
	
	SET NOCOUNT ON;

   SELECT DISTINCT(RegionFiscal) FROM dbo.PR_Pozo
END