-- =============================================
-- Author:		Reyna Olvera
-- Create date: 01/03/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE CO_ExtraeInformacionDirectorOperacion
	-- Add the parameters for the stored procedure here
	@idUsuario int =0,
	@idContrato int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT DC.idDirectorContrato, DC.idDirector, DO.NombreCompleto, DC.idRegion, COR.Nombre, DC.razonSocial,
  COC.NumeroContrato, DC.idContrato FROM CO_DirectorContrato AS DC 
  INNER JOIN CO_DirectorOperaciones AS DO ON DC.idDirector = DO.idDirector
   INNER JOIN CO_Region AS COR ON DC.idRegion = COR.IdRegion 
   INNER JOIN CO_Contrato AS COC ON DC.idContrato = COC.IdContrato ORDER BY DC.idContrato
END

