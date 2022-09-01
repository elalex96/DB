-- =============================================
-- Author:		Miguel Gomez
-- Create date: Diciembre 2014
-- Description:	Inserta un nuevo registro
-- =============================================
-- Author Alter: Neri Garcia
-- Create date: 2021-08-31
-- Description: Se agrega campo IdCatManoObra
-- =============================================
-- Author Alter: Neri Garcia
-- Create date: 2021-08-31
-- Description: Se agrega campo IdCatManoObra
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	30 de Agosto del 2022
-- Descripción:				Se agregan los campos de Ajuste,DescripcionPartidaServicio,OrdenServicioOrdenCompra,Partida,
--							UnidadMedidaId,PrecioUnitario,CantidadReal
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_InsertaRegistroCEE]
    @IdPrograma INT,
    @IdFactura INT,
    @MontoRegistro DECIMAL(18, 4),
    @InicioEjecucion DATE,
    @FinEjecucion DATE,
    @Comentarios NVARCHAR(MAX),
    @MesPresentacion DATE,
    @IdEstado INT,
    @IdUsuarioCreadoPor INT,
    @IdUsuarioModPor INT,
    @FecMovto DATETIME,
    @IdInstalacion INT,
    @IdCuentaCSH INT,
    @Poliza INT,
    @IdPedimentoComprobante INT,
    @CvTipoDoc INT,
    @CostoAtrib BIT,
    @IdContrato INT,
    @IdGastoRubro INT,
    @PCN FLOAT,
    @IdCatManoObra INT,
    @PorcentajeMarkup FLOAT = 0,
    @RegistroConAjuste BIT NULL,
    @AsociadoIncrementoPMT BIT = NULL,
    @Ajuste VARCHAR(2000) NULL,
    @DescripcionPartidaServicio VARCHAR(2000) NULL,
    @OrdenServicioOrdenCompra VARCHAR(2000) NULL,
    @Partida VARCHAR(2000) NULL,
    @UnidadMedidaId INT NULL,
    @PrecioUnitario DECIMAL(18, 4) NULL,
    @CantidadReal FLOAT NULL,
    @EsDePetrovendor BIT = 0
AS
BEGIN
    SET @IdFactura = CASE
                         WHEN @IdFactura = 0 THEN
                             NULL
                         ELSE
                             @IdFactura
                     END;
    SET @IdPedimentoComprobante = CASE
                                      WHEN @IdPedimentoComprobante = 0 THEN
                                          NULL
                                      ELSE
                                          @IdPedimentoComprobante
                                  END;
    SET NOCOUNT ON;
    DECLARE @insertado INT;
    /*Seleccionar el mes de presentación del gasto*/
    SELECT @MesPresentacion = MesPresentacionCGI
    FROM dbo.CO_Contrato
    WHERE IdContrato = @IdContrato;
    /**/
    INSERT INTO CO_Registro
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
        [IdCatalogoCuentasSH],
        [Poliza],
        [IdPedimentoComprobante],
        [CvTipoDocFacturacion],
        [CostosAtribuiblesAdministracion],
        [IdGastoRubro],
        [PCN],
        [IdCatManoObra],
        [AsociadoIncrementoPMT]
    )
    VALUES
    (@IdPrograma,
     @IdFactura,
     @MontoRegistro,
     @InicioEjecucion,
     @FinEjecucion,
     @Comentarios,
     @MesPresentacion,
     10004,
     @IdUsuarioCreadoPor,
     CURRENT_TIMESTAMP,
     @IdInstalacion,
     @IdCuentaCSH,
     @Poliza,
     @IdPedimentoComprobante,
     @CvTipoDoc,
     @CostoAtrib,
     @IdGastoRubro,
     @PCN,
     @IdCatManoObra,
     @AsociadoIncrementoPMT
    );
    SELECT @insertado = @@IDENTITY;

    IF (@EsDePetrovendor = 1)
    BEGIN
        UPDATE CO_Registro
        SET [Ajuste] = @Ajuste,
            [DescripcionPartidaServicio] = @DescripcionPartidaServicio,
            [OrdenServicioOrdenCompra] = @OrdenServicioOrdenCompra,
            [Partida] = @Partida,
            [UnidadMedidaId] = CASE
                                   WHEN @UnidadMedidaId = 0 THEN
                                       NULL
                                   ELSE
                                       @UnidadMedidaId
                               END,
            [PrecioUnitario] = @PrecioUnitario,
            [CantidadReal] = @CantidadReal
        WHERE IdRegistro = @insertado;
    END

    EXEC [SP_GuardaPorcentajePorRegistroId] @IdContrato,
                                            @IdUsuarioCreadoPor,
                                            @insertado,
                                            @PorcentajeMarkup,
                                            @MontoRegistro;
    SELECT @insertado AS INSERTADO,
           CONCAT('El registro se ha guardado exitosamente con el id ', @insertado) AS MSG;
END;