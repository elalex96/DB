-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/07/2018
-- Description:	obtener los documentos del proveedor y relacionarlos en caso de que el proveedor no contenga los documentos minimos que la operadora señalo como requeridos entonces
-- el proveedor no debe poder cotizar
-- =============================================

CREATE PROCEDURE SP_ObtenerDocumentosMinimos @IdSolPed INT, @IdOferta INT
AS
	BEGIN
		-- Se retorna los nombres de los documentos faltantes
		-- por lo tanto tiene que cargar esos documentos para poder cotizar la peticion oferta
		-- Si la cotizacion ya fue vencida entonces no es necesario mostrar la alerta
		DECLARE @FechaFinzalizacion DATETIME, @IdTipoRegimen INT

		SELECT		@FechaFinzalizacion = TAO.FechaFinalizacion
		FROM		dbo.MM_SolicitudPedido solPed
		INNER JOIN	dbo.TA_Operacion TAO
			ON TAO.IdDocumento = solPed.IdSolicitudPedido
		INNER JOIN	dbo.MM_PeticionOferta PO
			ON PO.IdSolicitudPedido = solPed.IdSolicitudPedido
		WHERE
					solPed.IdSolicitudPedido = @IdSolPed
					AND PO.IdPeticionOferta = @IdOferta
					AND TAO.IdTipoOperacion = 6

		SELECT		@IdTipoRegimen = prov.IdTipoRegimen
		FROM		dbo.MM_PeticionOferta PO
		INNER JOIN	dbo.S_Proveedor prov
			ON prov.IdProveedor = PO.IdSubcontratista
		WHERE
					PO.IdPeticionOferta = @IdOferta
					AND PO.IdSolicitudPedido = @IdSolPed

		IF ( @FechaFinzalizacion > GETDATE ())
			BEGIN
				SELECT	STUFF (
							(	SELECT		CAST(', ' AS VARCHAR(MAX)) + td.NombreTipoDocumento
								FROM		RN_DocumentosMinimosProveedor rn
								INNER JOIN	S_TipoDocumento td
									ON td.IdTipoDocumento = rn.IdTipoDocumento
								WHERE
											rn.IdTipoDocumento NOT IN
												(	SELECT		docS3.IdTipoDocumento --Son los documentos que tiene carga el proveedor
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
																AND docS3.Activo = 1 )
											AND rn.IdSolicitudPedido = @IdSolPed
											AND rn.IdTipoRegimen =  @IdTipoRegimen
								ORDER BY	td.NombreTipoDocumento
								FOR XML PATH ( '' )), 1, 1, '' ) AS DocumentosFaltantes
			END
		ELSE 
			SELECT NULL
	END