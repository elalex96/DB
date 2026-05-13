-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <02/07/2017>
-- Description:	<Consulta la infomacion del documento>
-- =============================================

CREATE PROCEDURE [dbo].[sp_ConsultarDocRecSolped]
	-- Add the parameters for the stored procedure here
	@IdDoc INT
AS
	BEGIN
		SELECT	IdSolPedMaterialDocumentoAdj, IdSolPedDetalle, ArchivoAdjuntoMaterial, NombreArchivoAdjunto
		--SG.IdSistemaGestion, DSG.DocSistemaGestion, SG.NombreCertificacion, Documento, Activo
		FROM	MM_SolPedArchivoAdjuntoMaterial
		WHERE
				IdSolPedDetalle = @IdDoc
				AND Activo = 1
	END