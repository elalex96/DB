-- =============================================
-- Author:		Pedro Acuña
-- Create date: 19/07/2018
-- Description:	obtener cuales son los documentos minimos que esta solicitando la operadora y marcar los que no se tienen, 
-- los que contienen valor nulo son documentos que no tiene cargado
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
			ON prov.IdProveedor = PO.IdSubcontratista
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
			ON prov.IdProveedor = PO.IdSubcontratista
		INNER JOIN	dbo.S_TipoDocumentoTipoPersona relTipoDoc
			ON relTipoDoc.IdTipoRegimen = prov.IdTipoRegimen
		INNER JOIN	dbo.S_Documento_S3 docS3
			ON docS3.IdProveedor = prov.IdProveedor
			   AND	docS3.IdTipoDocumento = relTipoDoc.IdTipoDocumento
		WHERE
					IdPeticionOferta = @IdOferta
					AND PO.IdSolicitudPedido = @IdSolPed
					AND docS3.Activo = 1
		GROUP BY docS3 .IdTipoDocumento

		SELECT		td.NombreTipoDocumento, rn.IdTipoDocumento, aux.IdTipoDocumento
		FROM		RN_DocumentosMinimosProveedor rn
		INNER JOIN	S_TipoDocumento td
			ON td.IdTipoDocumento = rn.IdTipoDocumento
		LEFT JOIN	@tablaAux aux
			ON aux.IdTipoDocumento = rn.IdTipoDocumento
		WHERE
					rn.IdSolicitudPedido = @IdSolPed
					AND rn.IdTipoRegimen = @IdTipoRegimen
	END
