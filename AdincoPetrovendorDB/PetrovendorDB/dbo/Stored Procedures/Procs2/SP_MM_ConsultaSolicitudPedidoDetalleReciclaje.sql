-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 24-04-17
-- Description: Consulta Solicitud Pedido Detalle 
-- Update: 30-08-2018
-- Agregue consulta para hacer referencia a mm_maestro
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudPedidoDetalleReciclaje]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
	BEGIN
		SET NOCOUNT ON 

		-- Insert statements for procedure here
		SELECT		SPD.IdSolicitudPedidoDetalle, MM.TextoCorto AS DescripcionCorta, MM.IdMaestro AS IdMaterial ,
					SPD.Cantidad, SPD.Observaciones, U.IdUnidad, SPD.IdDomicilioEntrega, MM.TextoLargo ,
					ISNULL ( DOC.IdSolPedMaterialDocumentoAdj, 0 ) AS IdDocumento ,
					( CASE WHEN ISNULL ( DOC.IdSolPedMaterialDocumentoAdj, 0 ) > 0 THEN
							   'Documento'
					  ELSE
						  'Ninguno'
					  END ) AS Adjunto, DOC.NombreArchivoAdjunto ,
					ISNULL ( DOC.ArchivoAdjuntoMaterial, '' ) AS ArchivoAdjuntoMaterial, SPD.IdCentroCosto
		FROM		MM_SolicitudPedidoDetalle AS SPD
		INNER JOIN	MM_Maestro AS MM
			ON MM.IdMaestro = SPD.IdMaterial
		INNER JOIN	PV_MM_MaterialSubFamilia AS SF
			ON SF.IdSubFamilia = MM.IdSubFamilia
		INNER JOIN	PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS GF
			ON GF.IdSubFamilia = SF.IdSubFamilia
		INNER JOIN	PV_MM_MaterialUnidad AS U
			ON U.IdUnidad = GF.IdUnidad
		LEFT JOIN	DG_Domicilio AS D
			ON D.IdDomicilio = SPD.IdDomicilioEntrega
		LEFT JOIN	MM_SolPedArchivoAdjuntoMaterial AS DOC
			ON DOC.IdSolPedDetalle = SPD.IdSolicitudPedidoDetalle
			   AND	DOC.Activo = 1
		WHERE		IdSolicitudPedido = @IdSolicitudPedido
	END