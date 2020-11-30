-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <24-09-2018>
-- Description:	<llenar el combo de tipo documento para restringir los documentos que solo se deben de cargar una vez>
-- =============================================
-- Author:		<Marcos Garcia>
-- Create date: <27-05-2019>
-- Description:	<Agregar la restriccion de Documentos Anexos solo si hay pedido>
-- =============================================
--
CREATE PROCEDURE [dbo].[ADM_CmbTipoDocumentoS3] --18615
@IdSolicitudPedido INT
AS
	BEGIN
		DECLARE @tablaNoMostrar TABLE
			( Id INT )

		DECLARE @TipoProceso INT

		--Si ya se ah cargado un documento de tipo fianza o de bases solo debe existir una vez
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
				INSERT INTO @tablaNoMostrar ( Id ) SELECT 3		-- Fianza
			END

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
				INSERT INTO @tablaNoMostrar ( Id ) SELECT 4		-- Bases
			END

		--si todavia no se ah enviado a la peticion oferta entonces todavia no debe de aparecer en el combo
		IF NOT EXISTS ( SELECT 1  FROM dbo .MM_PeticionOferta WHERE IdSolicitudPedido = @IdSolicitudPedido )
			BEGIN
				INSERT INTO @tablaNoMostrar ( Id ) SELECT 3		-- Fianza

				INSERT INTO @tablaNoMostrar ( Id ) SELECT 4		-- Bases

				INSERT INTO @tablaNoMostrar ( Id ) SELECT 5		-- Adj Directa Justificacion solOferta

				INSERT INTO @tablaNoMostrar ( Id ) SELECT 6		-- Mercadeo Justificacion solOferta

				INSERT INTO @tablaNoMostrar ( Id ) SELECT 7		-- Aceptacion de servicio

				INSERT INTO @tablaNoMostrar ( Id ) SELECT 8		-- Documentos por material Cotizacion/Oferta por Material

				INSERT INTO @tablaNoMostrar ( Id ) SELECT 9		-- Documentos Anexos Cotizacion/Oferta por Material 
			END

		--sino tiene una aceptacion de pedido entonces no mostrarlo
		IF NOT EXISTS
			(	SELECT		1
				FROM		dbo.MM_AceptacionPedido ap
				INNER JOIN	dbo.MM_Pedido p
					ON p.IdPedido = ap.IdPedido
				WHERE		p.IdSolicitudPedido = @IdSolicitudPedido )
			BEGIN
				INSERT INTO @tablaNoMostrar ( Id ) SELECT 7		-- Aceptacion de servicio
			END
			-- si no tiene pedido entonces no mostrarlo 
			IF NOT EXISTS
			(			SELECT 1 
				FROM Petrovendor.dbo.MM_Pedido WHERE IdSolicitudPedido = @IdSolicitudPedido )
			BEGIN
				INSERT INTO @tablaNoMostrar ( Id ) SELECT 10		-- Documentos Anexos Pedido
			END

		--Si la adjudicacion directa mostrar solo la directa o se si fue por mercadeo solo msotrar la de mercadeo
		SELECT	@TipoProceso = solPed.IdTipoProceso
		FROM	dbo.MM_SolicitudPedido solPed
		WHERE	solPed.IdSolicitudPedido = @IdSolicitudPedido

		IF ( @TipoProceso = 2 ) -- Mercadeo
			BEGIN
				INSERT INTO @tablaNoMostrar ( Id ) SELECT 5		-- Adj Directa Justificacion solOferta
			END

		IF ( @TipoProceso = 4 ) -- ADj Directa
			BEGIN
				INSERT INTO @tablaNoMostrar ( Id ) SELECT 6		-- Mercadeo Justificacion solOferta
			END
  
		SELECT	IdDocumento, TipoDocumento
		FROM	dbo.ADM_TipoDocumentosS3
		WHERE
				IdDocumento NOT IN
					( SELECT Id	   FROM @tablaNoMostrar )
	END