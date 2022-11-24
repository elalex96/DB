-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/07/2018
-- Description:	obtener los documentos del proveedor y relacionarlos en caso de que el proveedor no contenga los documentos minimos que la operadora señalo como requeridos entonces
-- el proveedor no debe poder cotizar
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_ObtenerDocumentosMinimos]
@IdSolPed INT, 
@IdOferta INT
AS
	BEGIN
		-- Se retorna los nombres de los documentos faltantes
		-- por lo tanto tiene que cargar esos documentos para poder cotizar la peticion oferta
		-- Si la cotizacion ya fue vencida entonces no es necesario mostrar la alerta
		DECLARE @FechaFinzalizacion DATETIME, @IdTipoRegimen INT

		SELECT		@FechaFinzalizacion = TAO.FechaFinalizacion
		FROM		dbo.MM_SolicitudPedido solPed
		JOIN	dbo.TA_Operacion TAO (NOLOCK)
			ON solPed.IdSolicitudPedido = TAO.IdDocumento
		JOIN	dbo.MM_PeticionOferta PO   (NOLOCK)
			ON solPed.IdSolicitudPedido = PO.IdSolicitudPedido
		WHERE
					solPed.IdSolicitudPedido = @IdSolPed
					AND PO.IdPeticionOferta = @IdOferta
					AND TAO.IdTipoOperacion = 6 -->CTE 

		SELECT		@IdTipoRegimen = prov.IdTipoRegimen
		FROM		dbo.MM_PeticionOferta PO   (NOLOCK)
		JOIN	dbo.S_Proveedor prov  (NOLOCK)
			ON PO.IdSubcontratista = prov.IdProveedor
		WHERE
					PO.IdPeticionOferta = @IdOferta
					AND PO.IdSolicitudPedido = @IdSolPed

		IF ( @FechaFinzalizacion > GETDATE ())
			BEGIN
				SELECT	STUFF (
							(	SELECT		CAST(', ' AS VARCHAR(MAX)) + td.NombreTipoDocumento
								FROM		RN_DocumentosMinimosProveedor rn  (NOLOCK)
								JOIN	S_TipoDocumento td  (NOLOCK)
									ON  rn.IdTipoDocumento = td.IdTipoDocumento 
								WHERE
											rn.IdTipoDocumento NOT IN
												(	SELECT		docS3.IdTipoDocumento --Son los documentos que tiene carga el proveedor
													FROM		dbo.MM_PeticionOferta PO (NOLOCK)
													JOIN	dbo.S_Proveedor prov (NOLOCK)
														ON PO.IdSubcontratista = prov.IdProveedor
													JOIN	dbo.S_TipoDocumentoTipoPersona relTipoDoc (NOLOCK)
														ON prov.IdTipoRegimen = relTipoDoc.IdTipoRegimen
													JOIN	dbo.S_Documento_S3 docS3 (NOLOCK)
														ON prov.IdProveedor = docS3.IdProveedor
														   AND	relTipoDoc.IdTipoDocumento =docS3.IdTipoDocumento
													WHERE
																PO.IdPeticionOferta = @IdOferta
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