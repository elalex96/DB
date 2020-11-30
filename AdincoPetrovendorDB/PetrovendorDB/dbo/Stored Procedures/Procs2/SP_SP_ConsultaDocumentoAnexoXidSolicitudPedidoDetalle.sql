-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10/01/2018>
-- Description:	<Consulta del documento anexo por IdSolicitudPedidoDetalle>
-- =============================================

CREATE procedure SP_SP_ConsultaDocumentoAnexoXidSolicitudPedidoDetalle --5761
	@IdSolicitudPedidoDetalle INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdSolPedMaterialDocumentoAdj, ISNULL([NombreArchivoAdjunto],'Documento.'), ArchivoAdjuntoMaterial
			FROM MM_SolPedArchivoAdjuntoMaterial
			WHERE IdSolPedDetalle = @IdSolicitudPedidoDetalle
			AND Activo = 1
END