CREATE PROCEDURE [dbo].[CO_sp_InsertaRegistroPorLayout]
     @IdContrato INT,
	 @IdUsuario INT,
    @IdPresupuesto INT,
    @IdLineaPresupuesto INT,
    @MontoRegistro FLOAT,
    @FechaInicioEjecucion datetime,
    @FechaFinEjecucion datetime,
    @Comentarios VARCHAR(1000),
    @MesPresentacion datetime,
    @IdPozo INT,
    @IdCuentaSH INT,
    @PolizaContable  INT,
    @CostosAtribuibles INT,
    @PCN FLOAT,
    @IdGastoRubro INT,
    @IdFactura INT NULL,
    @IdPedimento INT NULL,
	@IdArchivo INT 

AS
BEGIN

    SET NOCOUNT ON;
	DECLARE @insertado INT=0;
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
        [AsociadoIncrementoPMT],
		BitPCNP
    )
    VALUES
    (@IdLineaPresupuesto,
     CASE
		WHEN ISNULL(@IdFactura,0) > 0
		THEN @IdFactura
		ELSE NULL
	END,
     @MontoRegistro,
     @FechaInicioEjecucion,
     @FechaFinEjecucion,
     @Comentarios,
     @MesPresentacion,
     10004,
     @IdUsuario,
     GETDATE(),
     @IdPozo,
     @IdCuentaSH,
     @PolizaContable,
	 CASE
		WHEN ISNULL(@IdPedimento,0) > 0
		THEN @IdPedimento
		ELSE NULL
	END,
	 CASE
		WHEN ISNULL(@IdFactura,0) > 0
		THEN 1
		ELSE 3
	END,
     @CostosAtribuibles,
     @IdGastoRubro,
     @PCN,
     0,
     0,
	 0
    );
	
	SET @insertado =  SCOPE_IDENTITY(); 
	SELECT  @insertado;
	INSERT INTO CO_ArchivoLayoutGastoBitacora(AWSDocumentoId,GastoId,CreadoEl,CreadoPor)
	VALUES(@IdArchivo,@insertado,GETDATE(),@IdUsuario);

END