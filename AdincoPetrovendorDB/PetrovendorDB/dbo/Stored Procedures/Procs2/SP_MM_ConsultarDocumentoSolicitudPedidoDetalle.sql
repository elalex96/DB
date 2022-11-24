-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author: Daniel AC
-- Update date: 27/04/18
-- Description: Consulta de documento de pedido detalle con retorno de campos de las propiedades del documento
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarDocumentoSolicitudPedidoDetalle]
	-- Add the parameters for the stored procedure here
	@IdDocumento INT
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		-- Insert statements for procedure here	
		SELECT		IdSolPedMaterialDocumentoAdj, ISNULL ( [NombreArchivoAdjunto], 'Documento.' ), ArchivoAdjuntoMaterial ,
					DSPD.Carpeta, DSPD.Identificador, DSPD.Extension, DSPD.Mime
		FROM		MM_SolPedArchivoAdjuntoMaterial AS DSPD (NOLOCK)
		JOIN	MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
			ON DSPD.IdSolPedDetalle = SPD.IdSolicitudPedidoDetalle 
		WHERE
					DSPD.IdSolPedMaterialDocumentoAdj = @IdDocumento
					AND DSPD.Activo = 1
	END