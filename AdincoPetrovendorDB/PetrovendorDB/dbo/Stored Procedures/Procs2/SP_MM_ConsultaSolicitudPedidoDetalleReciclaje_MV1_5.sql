-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 19-12-17
-- Description: Consulta Solicitud Pedido Detalle  
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudPedidoDetalleReciclaje_MV1_5]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT ,

	/*--------------------
	parametros contrato 
   --------------------*/
	@IdContrato INT = NULL, @IdUsuario INT = NULL, @FechaRegistro DATETIME = NULL
/*--------------------
   --------------------*/
AS
	BEGIN
		SET NOCOUNT ON

		-- Insert statements for procedure here
		SELECT		SPD.IdSolicitudPedidoDetalle, MM.IdMaterial AS IdMaterial, MM.DescripcionCorta AS DescripcionCorta ,
					MM.DescripcionLarga AS DescripcionLarga, U.Unidad AS NombreUnidad ,
					ISNULL ( SPD.IdUnidad, 0 ) AS IdUnidad, SPD.Cantidad, SPD.Observaciones AS comentario ,
					SPD.IdDomicilioEntrega, ISNULL ( DOC.IdSolPedMaterialDocumentoAdj, 0 ) AS IdDocumento ,
					( CASE WHEN ISNULL ( DOC.IdSolPedMaterialDocumentoAdj, 0 ) > 0 THEN
							   'Documento'
					  ELSE
						  'Ninguno'
					  END ) AS EstatusArchivo
		FROM		MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
		INNER JOIN	dbo.MM_Material AS MM (NOLOCK)
			ON MM.IdMaterial = SPD.IdMaterial 
		LEFT JOIN	PV_MM_MaterialUnidad AS U (NOLOCK)
			ON U.IdUnidad = SPD.IdUnidad
		LEFT JOIN	DG_Domicilio AS D (NOLOCK)
			ON D.IdDomicilio = SPD.IdDomicilioEntrega
		LEFT JOIN	MM_SolPedArchivoAdjuntoMaterial AS DOC (NOLOCK)
			ON DOC.IdSolPedDetalle = SPD.IdSolicitudPedidoDetalle
			   AND	DOC.Activo = 1
		WHERE		IdSolicitudPedido = @IdSolicitudPedido
	END