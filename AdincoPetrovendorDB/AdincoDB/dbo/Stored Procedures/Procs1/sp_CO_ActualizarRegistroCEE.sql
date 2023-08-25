IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ActualizarRegistroCEE'
)
    DROP PROCEDURE sp_CO_ActualizarRegistroCEE;
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================  
-- Author:  Miguel Gomez  
-- Create date: Diciembre 2014  
-- Description: Inserta un nuevo registro  
-- ============================================= 
-- Author Alter: Neri Garcia
-- Create date: 2021-08-31
-- Description: Se agrega campo IdCatManoObra
-- =============================================
-- Author Alter: Reyna Olvera
-- Create date: 17/08/2022
-- Description: Se agrega campo RegistroConAjuste y AsociadoIncrementoPMT
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	30 de Agosto del 2022
-- Descripción:				Se agregan los campos de Ajuste,DescripcionPartidaServicio,OrdenServicioOrdenCompra,Partida,
--							UnidadMedidaId,PrecioUnitario,CantidadReal
-- =============================================
-- Author Alter: RO
-- Create date: 20230816
-- Description: Se modifica el parametro de poliza por un BIGINT para que pueda recibir valores mayores al int
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ActualizarRegistroCEE]
    @IdRegistro INT,
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
    @Poliza BIGINT,
    @IdPedimentoComprobante INT,
    @CvTipoDoc INT,
    @CostoAtrib BIT,
    @IdContrato INT,
    @IdGastoRubro INT,
    @PCN FLOAT,
    @IdCatManoObra INT,
    @CapexOpex int,
    @PorcentajeMarkup FLOAT = 0,
    @RegistroConAjuste BIT = NULL,
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
    /*Seleccionar el mes de presentación del gasto*/
    DECLARE @RegistroConAjusteActual BIT = 0;
    SELECT @MesPresentacion = MesPresentacionCGI
    FROM dbo.CO_Contrato	(NOLOCK)
    WHERE IdContrato = @IdContrato;

    SELECT @RegistroConAjusteActual = ISNULL(RegistroConAjuste, 0)
    FROM CO_Registro	(NOLOCK)
    WHERE IdRegistro = @IdRegistro;
    /**/

    UPDATE CO_Registro
    SET [IdPrograma] = @IdPrograma,
        [IdFactura] = CASE
                          WHEN @IdFactura = 0 THEN
                              NULL
                          ELSE
                              @IdFactura
                      END,
        [MontoRegistro] = @MontoRegistro,
        [InicioEjecucion] = @InicioEjecucion,
        [FinEjecucion] = @FinEjecucion,
        [Comentarios] = @Comentarios,
                            --[MesPresentacion] = @MesPresentacion,  
        [IdEstado] = 10004, --@IdEstado,  
                            --[IdUsuarioCreadoPor] = @IdUsuarioCreadoPor,  
        [IdUsuarioModPor] = @IdUsuarioModPor,
        [FecMovto] = @FecMovto,
        [IdInstalacion] = @IdInstalacion,
        [IdCatalogoCuentasSH] = @IdCuentaCSH,
        [Poliza] = @Poliza,
        [IdPedimentoComprobante] = CASE
                                       WHEN @IdPedimentoComprobante = 0 THEN
                                           NULL
                                       ELSE
                                           @IdPedimentoComprobante
                                   END,
        [CvTipoDocFacturacion] = @CvTipoDoc,
        [CostosAtribuiblesAdministracion] = @CostoAtrib,
        [IdGastoRubro] = CASE
                             WHEN @IdGastoRubro = 0 THEN
                                 NULL
                             ELSE
                                 @IdGastoRubro
                         END,
        [PCN] = @PCN,
        [IdCatManoObra] = @IdCatManoObra,
        CapexOpexEdicion = CASE
                               WHEN @CapexOpex = 1 THEN
                                   1
                               ELSE
                             0
                           END,
        RegistroConAjuste = CASE
                                WHEN @RegistroConAjusteActual = 0 THEN
                                    ISNULL(@RegistroConAjuste, 0)
                                ELSE
                                    @RegistroConAjusteActual
                            END,
        AsociadoIncrementoPMT = ISNULL(@AsociadoIncrementoPMT, 0),
        [Ajuste] = NULL,
        [DescripcionPartidaServicio] = NULL,
        [OrdenServicioOrdenCompra] = NULL,
        [Partida] = NULL,
        [UnidadMedidaId] = NULL,
        [PrecioUnitario] = NULL,
        [CantidadReal] = NULL
    WHERE IdRegistro = @IdRegistro;

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
        WHERE IdRegistro = @IdRegistro;
    END
    EXEC [SP_GuardaPorcentajePorRegistroId] @IdContrato,
                                            @IdUsuarioModPor,
                                            @IdRegistro,
                                            @PorcentajeMarkup,
                                            @MontoRegistro;

END;