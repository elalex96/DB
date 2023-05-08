---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <02/07/2017>
-- Description:	<Consulta la infomacion del documento>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarInfoDocumentoEvalucionFundes]
	-- Add the parameters for the stored procedure here
	@IdDoc int
AS
BEGIN
     
	 SELECT IdEvaluacionFundes, DocEvaluacion, P.RazonSocial
	 FROM PV_FundesEvaluacion AS FE
	 INNER JOIN S_Proveedor AS P ON P.IdProveedor = FE.ProveedorEvaluado
	 WHERE IdEvaluacionFundes = @IdDoc	 
END



