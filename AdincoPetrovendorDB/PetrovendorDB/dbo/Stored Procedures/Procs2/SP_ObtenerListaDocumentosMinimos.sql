-- =============================================
-- Author:		<Luis David>
-- Create date: <01/11/2021>
-- Description:	<Reacomodo de tablas para optimización>
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_ObtenerListaDocumentosMinimos] 
@IdSolPed INT, 
@IdOferta INT
AS
	BEGIN
		DECLARE @tablaAux TABLE
			( IdTipoDocumento INT )

		DECLARE @IdTipoRegimen INT

		SELECT		@IdTipoRegimen = prov.IdTipoRegimen
		FROM		dbo.MM_PeticionOferta PO (NOLOCK)
		JOIN	dbo.S_Proveedor prov (NOLOCK)
			ON PO.IdSubcontratista = prov.IdProveedor
		WHERE
		PO.IdPeticionOferta = @IdOferta
		AND PO.IdSolicitudPedido = @IdSolPed

		--SE GUARDAN EN LA TABLA LOS DOCUMENTOS QUE YA TIENE CARGADOS EL PROVEEDOR Y 
		--SE LE RELACIONAN CON LOS QUE LA OPERADORA ESTA SOLICITANDO PARA SABER CUALES NO TIENE
		INSERT INTO @tablaAux
			( IdTipoDocumento )
		SELECT		docS3.IdTipoDocumento
		FROM		dbo.MM_PeticionOferta PO (NOLOCK)
		JOIN	dbo.S_Proveedor prov (NOLOCK)
			ON PO.IdSubcontratista = prov.IdProveedor
		JOIN	dbo.S_TipoDocumentoTipoPersona relTipoDoc (NOLOCK)
			ON prov.IdTipoRegimen = relTipoDoc.IdTipoRegimen
		JOIN	dbo.S_Documento_S3 docS3 (NOLOCK)
			ON prov.IdProveedor = docS3.IdProveedor
			   AND	relTipoDoc.IdTipoDocumento = docS3.IdTipoDocumento
		WHERE
					PO.IdPeticionOferta = @IdOferta
					AND PO.IdSolicitudPedido = @IdSolPed
					AND docS3.Activo = 1
		GROUP BY docS3 .IdTipoDocumento

		SELECT		td.NombreTipoDocumento, rn.IdTipoDocumento, aux.IdTipoDocumento
		FROM		RN_DocumentosMinimosProveedor rn (NOLOCK)
		JOIN	S_TipoDocumento td (NOLOCK)
			ON rn.IdTipoDocumento = td.IdTipoDocumento
		LEFT JOIN	@tablaAux aux
			ON rn.IdTipoDocumento = aux.IdTipoDocumento
		WHERE
					rn.IdSolicitudPedido = @IdSolPed
					AND rn.IdTipoRegimen = @IdTipoRegimen
	END