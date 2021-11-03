DROP PROCEDURE IF EXISTS SP_ObtenerListaDocumentosMinimos
GO
-- =============================================
-- Author:		<Luis David>
-- Create date: <01/11/2021>
-- Description:	<Reacomodo de tablas para optimización>
-- =============================================
CREATE PROCEDURE SP_ObtenerListaDocumentosMinimos @IdSolPed INT, @IdOferta INT
AS
	BEGIN
		DECLARE @tablaAux TABLE
			( IdTipoDocumento INT )

		DECLARE @IdTipoRegimen INT

		SELECT		@IdTipoRegimen = prov.IdTipoRegimen
		FROM		dbo.MM_PeticionOferta PO
		INNER JOIN	dbo.S_Proveedor prov
			ON PO.IdSubcontratista = prov.IdProveedor
		WHERE
					PO.IdPeticionOferta = @IdOferta
					AND PO.IdSolicitudPedido = @IdSolPed

		--se guardan en la tabla los documentos que ya tiene cargados el proveedor y 
		--se le realcionan con los que la operadora esta solicitando para saber cuales no tiene
		INSERT INTO @tablaAux
			( IdTipoDocumento )
		SELECT		docS3.IdTipoDocumento
		FROM		dbo.MM_PeticionOferta PO
		INNER JOIN	dbo.S_Proveedor prov
			ON PO.IdSubcontratista = prov.IdProveedor
		INNER JOIN	dbo.S_TipoDocumentoTipoPersona relTipoDoc
			ON prov.IdTipoRegimen = relTipoDoc.IdTipoRegimen
		INNER JOIN	dbo.S_Documento_S3 docS3
			ON prov.IdProveedor = docS3.IdProveedor
			   AND	relTipoDoc.IdTipoDocumento = docS3.IdTipoDocumento
		WHERE
					IdPeticionOferta = @IdOferta
					AND PO.IdSolicitudPedido = @IdSolPed
					AND docS3.Activo = 1
		GROUP BY docS3 .IdTipoDocumento

		SELECT		td.NombreTipoDocumento, rn.IdTipoDocumento, aux.IdTipoDocumento
		FROM		RN_DocumentosMinimosProveedor rn
		INNER JOIN	S_TipoDocumento td
			ON rn.IdTipoDocumento = td.IdTipoDocumento
		LEFT JOIN	@tablaAux aux
			ON rn.IdTipoDocumento = aux.IdTipoDocumento
		WHERE
					rn.IdSolicitudPedido = @IdSolPed
					AND rn.IdTipoRegimen = @IdTipoRegimen
	END
