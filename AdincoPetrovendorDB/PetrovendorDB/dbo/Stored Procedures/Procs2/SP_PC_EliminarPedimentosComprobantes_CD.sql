
CREATE PROCEDURE [dbo].[SP_PC_EliminarPedimentosComprobantes_CD]
    @IdProveedor INT,
    @IdUsuario INT,
    @IdDocumento INT,
    @TipoEliminacion NVARCHAR(MAX),
    @Comentario NVARCHAR(MAX),
    @ContratoId INT
AS
BEGIN

    DECLARE @ESTATUS_APROBACION VARCHAR(MAX);
    DECLARE @ID_ELIMINADO INT;
    DECLARE @EXISTE_DOCUMENTO INT;
	DECLARE @TipoDocumentoActual VARCHAR(MAX)
	DECLARE @ID_OPERACION INT
    /*VALIDAR EL TIPO DE DOCUMENTO A ELIMINAR */
	IF @TipoEliminacion='PEDIMENTO'
		SET @TipoDocumentoActual='pedimento'

	IF @TipoEliminacion='COMPROBANTE_EXTR'
		SET @TipoDocumentoActual='comprobante extranjero'
	
	IF @TipoEliminacion NOT IN ('PEDIMENTO','COMPROBANTE_EXTR')
		BEGIN
			  SELECT 'ERROR_ELIMINACION',
                   'Error al indicar tipo de eliminación';
            RETURN;
		END 
        /*VALIDAR QUE EL ESTATUS ACTUAL SEA RECHAZADO */


        SELECT @ESTATUS_APROBACION = TE.Nombre,
               @ID_ELIMINADO = PC.IdEliminado,
               @EXISTE_DOCUMENTO = PC.IdPedimentoComprobante,
			   @ID_OPERACION=OP.IdOperacion
        FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
            JOIN dbo.TA_Operacion AS OP
                ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
                   AND OP.IdTipoOperacion = 19
                   AND OP.IdProveedor = APC.IdProveedor
            JOIN dbo.FI_PedimentoComprobante AS PC
                ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
            JOIN dbo.TA_Estatus AS TE
                ON TE.IdEstatus = OP.IdEstatusOperacion
        WHERE APC.IdProveedor = @IdProveedor
              AND PC.IdPedimentoComprobante = @IdDocumento
              --AND PC.CvTipoDocFacturacion = 2 --> TIPO PEDIMENTO
        GROUP BY TE.Nombre,
                 PC.IdEliminado,
                 PC.IdPedimentoComprobante,
				 OP.IdOperacion

        IF ISNULL(@EXISTE_DOCUMENTO, 0) = 0
        BEGIN
            SELECT 'ERROR_ELIMINACION',
                   CONCAT('No se encontró el ',@TipoDocumentoActual,' solicitado a eliminar');
            RETURN;
        END;


        IF ISNULL(@ESTATUS_APROBACION, '') = 'Aprobada'
        BEGIN
            SELECT 'ERROR_ELIMINACION',
                   CONCAT('Este ',@TipoDocumentoActual,' ya esta aprobado, no es posible eliminarlo');
            RETURN;
        END;

        IF ISNULL(@ID_ELIMINADO, 0) > 0
        BEGIN
            SELECT 'SUCCESS',
                   'YA SE ENCUENTRA ELIMINADO';
			RETURN;
        END;

        INSERT INTO dbo.AD_RegistroEliminacion
        (
            IdUsuario,
            FechaRegistro,
            ComentarioExterno,
            ComentarioInterno,
            TipoEliminacion,
            Activo,
            IdProveedor,
            IdContrato,
            IdProceso,
            Confirmacion
        )
        VALUES
        (   @IdUsuario,      -- IdUsuario - int
            GETDATE(),       -- FechaRegistro - datetime	
            @Comentario,     -- ComentarioExterno - nvarchar(max)
            @Comentario,     -- ComentarioInterno - nvarchar(max)
            CONCAT(@TipoEliminacion,'-CD'), -- TipoEliminacion - nvarchar(100)
            1,               -- Activo - bit
            @IdProveedor,    -- IdProveedor - int
            @ContratoId,     -- IdContrato - int
            @IdDocumento,    -- IdProceso - int
            1                -- Confirmacion - bit
            );

        SELECT @ID_ELIMINADO = SCOPE_IDENTITY();

		/*ACTUALIZAR ESTATUS ELIMINADA AL PEDIMENTO Y AL APROBACIÓN/OPERACIÓN*/
        UPDATE dbo.FI_PedimentoComprobante
        SET ModificadoPor = @IdUsuario,
            ModificadoEn = GETDATE(),
            IdEstatusEliminado = 1,
            IdEliminado = @ID_ELIMINADO
        WHERE IdPedimentoComprobante = @IdDocumento;

		UPDATE dbo.TA_Operacion
		SET IdEstatusEliminado=1,
		IdEliminado=@ID_ELIMINADO
		WHERE IdOperacion=@ID_OPERACION

        SELECT 'SUCCESS',
               'ELIMINACIÓN REALIZADA';

END;


