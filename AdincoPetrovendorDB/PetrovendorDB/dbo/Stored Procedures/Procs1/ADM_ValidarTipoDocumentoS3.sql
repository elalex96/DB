-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <24-09-2018>
-- Description:	<validar que el tipo de documento no haya sido cargado>
-- =============================================

CREATE PROCEDURE ADM_ValidarTipoDocumentoS3 @TipoDocumento INT, @IdSolicitudPedido INT
AS
	BEGIN
		DECLARE @Existe BIT = 0

		IF ( @TipoDocumento = 3 )
			BEGIN
				IF EXISTS
					(	SELECT		1
						FROM		TA_DocFianzaOperacion doc
						INNER JOIN	dbo.TA_Operacion TAO
							ON TAO.IdOperacion = doc.IdOperacion
						INNER JOIN	dbo.MM_SolicitudPedido solPed
							ON TAO.IdDocumento = solPed.IdSolicitudPedido
						WHERE
									doc.IdOperacion IN
										(	SELECT	IdOperacion
											FROM	dbo.TA_Operacion
											WHERE
													IdDocumento = @IdSolicitudPedido
													AND IdTipoOperacion = 6 )
									AND doc.Activo = 1
									AND TAO.IdTipoOperacion = 6 )
					BEGIN
						SELECT @Existe =  1 -- Fianza
					END
			END

		IF ( @TipoDocumento = 4 )
			BEGIN
				IF EXISTS
					(	SELECT		1
						FROM		dbo.TA_DocBasesOperacion doc
						INNER JOIN	dbo.TA_Operacion TAO
							ON TAO.IdOperacion = doc.IdOperacion
						INNER JOIN	dbo.MM_SolicitudPedido solPed
							ON TAO.IdDocumento = solPed.IdSolicitudPedido
						WHERE
									doc.IdOperacion IN
										(	SELECT	IdOperacion
											FROM	dbo.TA_Operacion
											WHERE
													IdDocumento = @IdSolicitudPedido
													AND IdTipoOperacion = 6 )
									AND doc.Activo = 1
									AND TAO.IdTipoOperacion = 6 )
					BEGIN
						SELECT @Existe =  1 -- Bases
					END
			END
	END