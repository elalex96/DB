IF OBJECT_ID('[dbo].[USP_DEL_FI_EliminarRelacionEPT]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].USP_DEL_FI_EliminarRelacionEPT
GO

CREATE PROCEDURE [dbo].USP_DEL_FI_EliminarRelacionEPT
@IdContrato INT, 
@IdUsuario  INT, 
@IdEPT      INT,
@IdDocumento INT,
@EsDetalle BIT,
@TipoComprobante VARCHAR(50)
AS
BEGIN
    DECLARE @NombreEstudio VARCHAR(2000),
            @NombreUsuario VARCHAR(200),
            @TipoPI INT = 2,
            @TipoPE INT = 3,
            @MensajeFactura VARCHAR(MAX), 
            @MensajePedimento VARCHAR(MAX);

    SET @TipoComprobante = UPPER(@TipoComprobante);

    SELECT @NombreUsuario = ISNULL(Nombre, 'Desconocido') 
    FROM AP_Usuario WHERE UsuarioID = @IdUsuario;

    SELECT @NombreEstudio = ISNULL(Nombre, 'Desconocido') 
    FROM FI_EstudioPreciosTransfer WHERE IdEstudioPrecioTransfer = @IdEPT;

    IF (@EsDetalle = 1)
    BEGIN
        IF(@TipoComprobante IN ('I', 'P'))
        BEGIN
            INSERT INTO AP_Bitacora (Mensaje, Detalle, Tipo, Fecha, UsuarioId, ContratoId)
            SELECT CONCAT('El usuario ', @NombreUsuario, ' eliminó la relación'),
                   CONCAT('La factura con UUID [', UUID, '] se desligó del estudio [', @NombreEstudio, ']'),
                   'Eliminación',
                   GETDATE(),
                   @IdUsuario,
                   @IdContrato
            FROM FI_Factura (NOLOCK) WHERE IdFactura = @IdDocumento;

            UPDATE FI_Factura
            SET IdEstudioPrecioTransfer = NULL
            WHERE IdFactura = @IdDocumento;
        END

        IF(@TipoComprobante IN ('PE', 'PI'))
        BEGIN
            INSERT INTO AP_Bitacora (Mensaje, Detalle, Tipo, Fecha, UsuarioId, ContratoId)
            SELECT CONCAT('El usuario ', @NombreUsuario, ' eliminó la relación'),
                   CASE 
                       WHEN CvTipoDocFacturacion = @TipoPE 
                       THEN CONCAT('El comprobante [', IdDocFacturacionSIPAC, '] se desligó del estudio [', @NombreEstudio, ']')
                       WHEN CvTipoDocFacturacion = @TipoPI 
                       THEN CONCAT('El pedimento [', NumeroPedimento, '] se desligó del estudio [', @NombreEstudio, ']')
                   END,
                   'Eliminación',
                   GETDATE(),
                   @IdUsuario,
                   @IdContrato
            FROM FI_PedimentoComprobante (NOLOCK) WHERE IdPedimentoComprobante = @IdDocumento;

            UPDATE FI_PedimentoComprobante
            SET IdEstudioPrecioTransfer = NULL
            WHERE IdPedimentoComprobante = @IdDocumento;
        END
    END

    IF(@EsDetalle = 0)
		BEGIN
		-- Genera un mensaje con todos los UUID de las facturas
		SELECT @MensajeFactura =
			'Facturas con UUID: ' +
			STUFF(
				(
					SELECT ', ' + UUID
					FROM FI_Factura (NOLOCK) 
					WHERE IdEstudioPrecioTransfer = @IdEPT
					FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)')
			, 1, 2, '');
    
		-- Genera un mensaje con todos los datos de pedimentos/comprobantes
		SELECT @MensajePedimento =
			'Pedimentos/Comprobantes: ' +
			STUFF(
				(
					SELECT ', ' +
						CASE 
							WHEN CvTipoDocFacturacion = @TipoPE THEN CONCAT('PE: ', IdDocFacturacionSIPAC)
							WHEN CvTipoDocFacturacion = @TipoPI THEN CONCAT('PI: ', NumeroPedimento)
						END
					FROM FI_PedimentoComprobante (NOLOCK)
					WHERE IdEstudioPrecioTransfer = @IdEPT
					FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)')
			, 1, 2, '');

		-- Insertar un solo registro en bitácora para facturas
		IF @MensajeFactura IS NOT NULL AND @MensajeFactura <> ''
		BEGIN
			INSERT INTO AP_Bitacora (Mensaje, Detalle, Tipo, Fecha, UsuarioId, ContratoId)
			VALUES (CONCAT('El usuario ', @NombreUsuario, ' eliminó la relación'),
					CONCAT(@MensajeFactura, ' se desligaron del estudio [', @IdEPT,'][', @NombreEstudio, ']'),
					'Eliminación',
					GETDATE(),
					@IdUsuario,
					@IdContrato);
		END

		-- Insertar un solo registro en bitácora para pedimentos/comprobantes
		IF @MensajePedimento IS NOT NULL AND @MensajePedimento <> ''
		BEGIN
			INSERT INTO AP_Bitacora (Mensaje, Detalle, Tipo, Fecha, UsuarioId, ContratoId)
			VALUES (CONCAT('El usuario ', @NombreUsuario, ' eliminó la relación'),
					CONCAT(@MensajePedimento, ' se desligaron del estudio [', @IdEPT,'][', @NombreEstudio, ']'),
					'Eliminación',
					GETDATE(),
					@IdUsuario,
					@IdContrato);
		END

		-- Actualizar facturas si existen
		IF EXISTS (SELECT 1 FROM FI_Factura WHERE IdEstudioPrecioTransfer = @IdEPT)
		BEGIN
			UPDATE FI_Factura
			SET IdEstudioPrecioTransfer = NULL
			WHERE IdEstudioPrecioTransfer = @IdEPT;
		END

		-- Actualizar pedimentos/comprobantes si existen
		IF EXISTS (SELECT 1 FROM FI_PedimentoComprobante WHERE IdEstudioPrecioTransfer = @IdEPT)
		BEGIN
			UPDATE FI_PedimentoComprobante
			SET IdEstudioPrecioTransfer = NULL
			WHERE IdEstudioPrecioTransfer = @IdEPT;
		END


        -- Actualizar solo si hay registros
        IF EXISTS (SELECT 1 FROM FI_Factura WHERE IdEstudioPrecioTransfer = @IdEPT)
        BEGIN
            UPDATE FI_Factura
            SET IdEstudioPrecioTransfer = NULL
            WHERE IdEstudioPrecioTransfer = @IdEPT;
        END

        IF EXISTS (SELECT 1 FROM FI_PedimentoComprobante WHERE IdEstudioPrecioTransfer = @IdEPT)
        BEGIN
            UPDATE FI_PedimentoComprobante
            SET IdEstudioPrecioTransfer = NULL
            WHERE IdEstudioPrecioTransfer = @IdEPT;
        END
    END

    SELECT 1;
END
