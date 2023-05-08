-- =============================================
-- Author:		DANIEL Cruz
-- Create date: 12-06-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_EditarRegistroGasto]
	-- Add the parameters for the stored procedure here
@NumeroOperacion INT,
@IdFactura          INT,
@MontoRegistro      DECIMAL(18, 4),
@InicioEjecucion    DATE,
@FinEjecucion       DATE,
@Comentarios        NVARCHAR(MAX),
@IdUsuarioModPor    INT,
@IdInstalacion      INT,
@IdCuentaCSH	INT,
@Poliza  INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [dbo].[CO_Registro]
	SET [IdFactura]=@IdFactura,
          [MontoRegistro]=@MontoRegistro,
          [InicioEjecucion]=@InicioEjecucion,
          [FinEjecucion]=@FinEjecucion,
          [Comentarios]=@Comentarios,
          [MesPresentacion]=@FinEjecucion,
          [IdUsuarioModPor]=@IdUsuarioModPor,
          [FecMovto]= @FinEjecucion,
          [IdInstalacion]=@IdInstalacion ,
		[IdCatalogoCuentasSH]=@IdCuentaCSH,
		[Poliza]=@Poliza
    WHERE IdRegistro = @NumeroOperacion
END
