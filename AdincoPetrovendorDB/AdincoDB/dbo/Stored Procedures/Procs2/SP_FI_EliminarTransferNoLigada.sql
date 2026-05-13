IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_EliminarTransferNoLigada'
)
    DROP PROCEDURE SP_FI_EliminarTransferNoLigada
GO
-- =============================================
-- Author:		Manuel CD
-- Create date: 18-06-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarTransferNoLigada]
    @IdTransfer INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN

    SET NOCOUNT ON;
	--La tabla intermedia se ocupara para guardar los registros antes de borrarlos
	CREATE TABLE #TablaIntermedia (Datos Varchar(MAX), IdBitacora INT)
	DECLARE @IdBitacora INT,
			@NombreTablas VARCHAR(1000)

	INSERT INTO #TablaIntermedia (Datos)
	SELECT (SELECT 'FI_TransferFactura' AS Tabla, IdTransferFactura, IdTransfer, IdFactura, 
			IdPedimentoComprobante, MontoPagado, CvTipoDocFacturacion, CreadoPor, CreadoEn, 
			ModificadoPor, ModificadoEn
	FROM FI_TransferFactura (NOLOCK)
    WHERE IdTransfer = @IdTransfer
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	
	INSERT INTO #TablaIntermedia (Datos)
	SELECT (SELECT 'FI_Transfer' AS Tabla, IdTransferencia, IdContrato, IdComprobantePago, 
			NombreExtencionArchivo, ReferenciaBancaria, FechaPago, IdCuentaOrigen, IdCuentaDestino, 
			MontoPagado, IdMoneda, IdClasificacionDocumento, Concepto, IdMetodoPago, ProcesadoSIPAC, 
			NumeroPolizaContable, Intereses, CreadoPor, CreadoEn, ModificadoPor, ModificadoEn, 
			HashSHA256, IdFacturaPago, AWSPDFId, IdFormaPago, IdTransferenciaImportacion 
	FROM FI_Transfer (NOLOCK)
    WHERE IdTransferencia = @IdTransfer
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	
	INSERT INTO #TablaIntermedia (Datos)
	SELECT (SELECT 'Petrovendor..Ax_Pagos' AS Tabla, IdPago, IdTransferencia
    FROM Petrovendor..Ax_Pagos (NOLOCK)
    WHERE IdTransferencia = @IdTransfer
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	
	INSERT INTO #TablaIntermedia (Datos)
	SELECT (SELECT 'CO_SAPPaymentData' AS Tabla, IdTransferencia, IdContrato, SourceAccount, 
	FinalAccount, PaymentReference, PaymentDate, PaidAmount, InvoiceNumber
	FROM CO_SAPPaymentData (NOLOCK)
    WHERE IdTransferencia = @IdTransfer
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	
	INSERT INTO #TablaIntermedia (Datos)
	SELECT (SELECT 'FI_TransferFacturaPPD' AS Tabla, IdTransferFacturaPPD, IdTransfer, IdFactura
	FROM FI_TransferFacturaPPD (NOLOCK) 
    WHERE IdTransfer = @IdTransfer
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	UPDATE Petrovendor..Ax_Pagos 
	SET IdTransferencia = NULL
	WHERE IdTransferencia = @IdTransfer

	UPDATE CO_SAPPaymentData
	SET IdTransferencia = NULL
	WHERE IdTransferencia = @IdTransfer

	UPDATE FI_TransferFacturaPPD
	SET IdTransfer = NULL
	WHERE IdTransfer = @IdTransfer 

    DELETE dbo.FI_TransferFactura
    WHERE IdTransfer = @IdTransfer;

    DELETE dbo.FI_Transfer
    WHERE IdTransferencia = @IdTransfer;

	SELECT @NombreTablas = STUFF((SELECT ', ' + CAST(JSON_VALUE(Datos, '$.Tabla')  AS NVARCHAR)
            FROM #TablaIntermedia
            WHERE Datos IS NOT NULL
            FOR XML PATH('')), 1, 2, '') 

    INSERT INTO AP_Bitacora
    (
        [Fecha],
        [Tipo],
        [Mensaje],
        [Detalle],
        [UsuarioId],
        [ContratoId]
    )
    VALUES
    (GETDATE(),
     'Eliminación',
     CONCAT('Eliminación de registro en las tablas ', @NombreTablas, ' en la página MisTransferencias.aspx'),
     CONCAT('Se eliminó transferencia con identificador: ', CONVERT(VARCHAR(10), @IdTransfer)),
     @IdUsuario,
     @IdContrato
    );

	SELECT @IdBitacora = SCOPE_IDENTITY()

	INSERT INTO AP_BitacoraEliminados(IdBitacora, Datos, CreadoEl)
	SELECT @IdBitacora, Datos, GETDATE() FROM #TablaIntermedia
	WHERE Datos IS NOT NULL

    --
    IF @@ERROR <> 0
        SELECT 'false' AS msj;
    ELSE
        SELECT 'true' AS msj;
END;
