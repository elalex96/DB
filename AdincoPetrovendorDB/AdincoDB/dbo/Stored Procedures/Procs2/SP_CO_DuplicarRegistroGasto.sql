CREATE PROCEDURE [dbo].[SP_CO_DuplicarRegistroGasto]
    @IdRegistro INT,
    @IdContrato INT,
    @IdUsuario INT,
    @Accion INT,
    @Comentario VARCHAR(MAX),
    @MesPresentacion DATE
AS
BEGIN
	DECLARE @IdRegistroDuplicado INT;
    SET NOCOUNT ON;
    BEGIN TRY
	BEGIN TRAN;
        INSERT INTO [Adinco].[dbo].[CO_Registro]
        (
            [IdPrograma],
            [IdFactura],
            [MontoRegistro],
            [InicioEjecucion],
            [FinEjecucion],
            [Comentarios],
            [MesPresentacion],
            [IdEstado],
            [IdUsuarioCreadoPor],
            [FecMovto],
            [IdInstalacion],
            [CreadoPor],
            [Fila],
            [IdPedimentoComprobante],
            [CvTipoDocFacturacion],
            [IdCatalogoCuentasSH],
            [Poliza],
            [IsEditable],
            [CostosAtribuiblesAdministracion],
            [EstadoDePresentacion],
            [MesCertificadoCIEP],
            [IdGastoRubro],
            [PCN],
            [Importado],
            [BitPCNP],
            [IdCBSISH],
            [IdAceptacionPedidoDetalle],
            [MesGasto],
            [CapexOpexEdicion],
            [IdCatManoObra]
        )
        SELECT 
               [IdPrograma],
               [IdFactura],
               CASE
                   WHEN @Accion = 0 THEN
                       ABS([MontoRegistro]) * -1
                   ELSE
                       ABS([MontoRegistro]) * 1
               END,
               [InicioEjecucion],
               [FinEjecucion],
               @Comentario,
               @MesPresentacion,
               [IdEstado],
               @IdUsuario,
               GETDATE(),
               [IdInstalacion],
               @IdUsuario,
               [Fila],
               [IdPedimentoComprobante],
               [CvTipoDocFacturacion],
               [IdCatalogoCuentasSH],
               [Poliza],
               [IsEditable],
               [CostosAtribuiblesAdministracion],
               [EstadoDePresentacion],
               [MesCertificadoCIEP],
               [IdGastoRubro],
               [PCN],
               [Importado],
               [BitPCNP],
               [IdCBSISH],
               [IdAceptacionPedidoDetalle],
               [MesGasto],
               [CapexOpexEdicion],
               [IdCatManoObra]
        FROM [Adinco].[dbo].[CO_Registro]
        WHERE [IdRegistro] = @IdRegistro
        SET @IdRegistroDuplicado = SCOPE_IDENTITY();
        --
        IF EXISTS
        (
            SELECT *
            FROM [dbo].[CO_RegistroMarkup]
            WHERE GastoId = @IdRegistro
        )
        BEGIN
            INSERT INTO [Adinco].[dbo].[CO_RegistroMarkup]
            (
                [GastoId],
                [Porcentaje],
                [MontoEquivalente],
                [MontoGasto],
                [Activo],
                [CreadoPor],
                [CreadoEn],
                [ContratoId],
                [TipoCambio],
                [MesCertificado]
            )
            SELECT @IdRegistroDuplicado,
                   [Porcentaje],
                   CASE
                       WHEN @Accion = 0 THEN
                           ABS([MontoEquivalente]) * -1
                       ELSE
                           ABS([MontoEquivalente]) * 1
                   END,
                   CASE
                       WHEN @Accion = 0 THEN
                           ABS([MontoGasto]) * -1
                       ELSE
                           ABS([MontoGasto]) * 1
                   END,
                   [Activo],
                   [CreadoPor],
                   [CreadoEn],
                   [ContratoId],
                   [TipoCambio],
                   [MesCertificado]
            FROM [Adinco].[dbo].[CO_RegistroMarkup]
            WHERE Activo = 1
                  AND GastoId = @IdRegistro
        END
		
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        SELECT 'ERROR MESSAGE: ' + ERROR_MESSAGE() + ' - ERROR PROCEDURE: ' + ERROR_PROCEDURE() + ' - ERROR LINE: '
               + CAST(ERROR_LINE() AS VARCHAR) AS Respuesta;
    END CATCH
	SELECT CAST(@IdRegistroDuplicado AS VARCHAR) AS Respuesta;
END