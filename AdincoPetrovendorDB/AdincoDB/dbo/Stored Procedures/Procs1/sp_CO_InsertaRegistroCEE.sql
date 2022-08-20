-- =============================================
-- Author:		Miguel Gomez
-- Create date: Diciembre 2014
-- Description:	Inserta un nuevo registro
-- =============================================
-- Author Alter: Neri Garcia
-- Create date: 2021-08-31
-- Description: Se agrega campo IdCatManoObra
-- =============================================
-- Author Alter: Reyna Olvera
-- Create date: 2022-08-18
-- Description: Se agrega campo cambios de edición con ajuste y de asociado al pmt
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
	@RegistroConAjuste BIT  NULL, 
	@AsociadoIncrementoPMT BIT  = NULL
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
        --[IdUsuarioModPor],
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
    (   @IdPrograma, @IdFactura, @MontoRegistro, @InicioEjecucion, @FinEjecucion, @Comentarios, @MesPresentacion,
        10004, @IdUsuarioCreadoPor,
        CURRENT_TIMESTAMP, @IdInstalacion, @IdCuentaCSH, @Poliza, @IdPedimentoComprobante, @CvTipoDoc, @CostoAtrib,
        @IdGastoRubro, @PCN, @IdCatManoObra,@AsociadoIncrementoPMT);
    SELECT @insertado = @@IDENTITY;

	EXEC [SP_GuardaPorcentajePorRegistroId] @IdContrato,@IdUsuarioCreadoPor,@insertado,@PorcentajeMarkup,@MontoRegistro;

    SELECT @insertado AS INSERTADO,
           CONCAT('El registro se ha guardado exitosamente con el id ', @insertado) AS MSG;
END;
