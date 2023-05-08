-- Stored Procedure
-- use adinco
CREATE PROCEDURE [dbo].[sp_CO_ActualizaRegistro_CEE]
	   @IdRegistro	    INT
	   ,@IdPrograma	    INT
	   ,@IdFactura	    INT
	   ,@MontoRegistro DECIMAL(18,4)
	   ,@InicioEjecucion   DATE
	   ,@FinEjecucion	   DATE
	   ,@Comentarios	   NVARCHAR(MAX)
	   ,@MesPresentacion   DATE
	   ,@IdUsuarioModPor   INT
	   ,@IdInstalacion	   INT
	   ,@IdPedimentoComprobante	 INT
	   ,@CvTipoDocFacturacion  INT
	   ,@IdCatalogoCuentasSH	  INT
	   ,@Poliza		   NVARCHAR(MAX)

AS
BEGIN
         -- =============================================
         -- Author:		Miguel Gomez
         -- Create date: 2017-06-03
         -- Description:	Actualizaciòn de registros en tabla CO_REgistro
         -- =============================================

UPDATE CO_Registro
    SET 
	   IdPrograma		   =	  @IdPrograma
	   ,IdFactura		   =	  @IdFactura
	   ,MontoRegistro	   =	  @MontoRegistro
	   ,InicioEjecucion	   =	  @InicioEjecucion
	   ,FinEjecucion	   =	  @FinEjecucion
	   ,Comentarios	   =	  @Comentarios
	   ,MesPresentacion	   =	  @MesPresentacion
	   ,IdUsuarioModPor	   =	  @IdUsuarioModPor
	   ,FecMovto		   =	  GETDATE()
	   ,IdInstalacion	   =	  @IdInstalacion
	   ,IdPedimentoComprobante =	 @IdPedimentoComprobante
	   ,CvTipoDocFacturacion	  =	 @CvTipoDocFacturacion
	   ,IdCatalogoCuentasSH	  =	 @IdCatalogoCuentasSH
	   ,Poliza		   =	  @Poliza
WHERE
    IdRegistro	 =	@IdRegistro

END

