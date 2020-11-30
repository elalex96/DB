-- =============================================
-- Author:		Josue Glez
-- Create date: 15-03-2017
-- Description:	Registra un volumen de comercializacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertaVolumenComercializacion]
		  @IdContrato int
           ,@MesReporte date
           ,@FechaTransaccion date
           ,@IdTipoHidrocarburo int
           ,@VolumenVendido float
           ,@PrecioVentaUnitario money
           ,@CostoUnitarioComercializacion money
           ,@PrecioPuntoMedicion money
           ,@IdFactura  int
           ,@NumeroFolioPedimento nvarchar(15)
           ,@EPT bit
           ,@OperacionBajoReglasMercado bit
           ,@ClasificacionDocumentoSoporte int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[COM_OperacionComercializacion]
           ([IdContrato]
           ,[MesReporte]
           ,[FechaTransaccion]
           ,[IdTipoHidrocarburo]
           ,[VolumenVendido]
           ,[PrecioVentaUnitario]
           ,[CostoUnitarioComercializacion]
           ,[PrecioPuntoMedicion]
           ,[IdFactura]
           ,[NumeroFolioPedimento]
           ,[EPT]
           ,[OperacionBajoReglasMercado]
           ,[ClasificacionDocumentoSoporte])
     VALUES
           (@IdContrato 
           ,datefromparts(year( @FechaTransaccion), month(@FechaTransaccion),1)
           ,@FechaTransaccion 
           ,@IdTipoHidrocarburo 
           ,@VolumenVendido 
           ,@PrecioVentaUnitario 
           ,@CostoUnitarioComercializacion 
           ,@PrecioPuntoMedicion 
           ,@IdFactura 
           ,@NumeroFolioPedimento 
           ,@EPT 
           ,@OperacionBajoReglasMercado 
           ,@ClasificacionDocumentoSoporte)

END
