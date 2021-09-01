-- =============================================  
-- Author:  Miguel Gomez  
-- Create date: Diciembre 2014  
-- Description: Inserta un nuevo registro  
-- ============================================= 
-- Author Alter: Neri Garcia
-- Create date: 2021-08-31
-- Description: Se agrega campo IdCatManoObra
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ActualizarRegistroCEE]  
    -- Add the parameters for the stored procedure here  
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
    @Poliza INT,  
    @IdPedimentoComprobante INT,  
    @CvTipoDoc INT,  
    @CostoAtrib BIT,  
    @IdContrato INT,  
    @IdGastoRubro INT,  
    @PCN FLOAT,
	@IdCatManoObra INT,
	@CapexOpex int  
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
  
    -- Insert statements for procedure here  
    /*Seleccionar el mes de presentación del gasto*/  
  
    SELECT @MesPresentacion = MesPresentacionCGI  
    FROM dbo.CO_Contrato  
    WHERE IdContrato = @IdContrato;  
  
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
		CapexOpexEdicion = case when @CapexOpex = 1 then 1 else 0 end  
    WHERE IdRegistro = @IdRegistro;  
END;