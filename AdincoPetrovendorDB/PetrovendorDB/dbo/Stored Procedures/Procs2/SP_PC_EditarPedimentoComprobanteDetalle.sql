-- =============================================
-- Author:		DANIEL AC
-- Create date: 27-03-18
-- Description:	Ediatr Detalle de pedimento comprobante 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_EditarPedimentoComprobanteDetalle] 
	-- Add the parameters for the stored procedure here

@IdProveedor        INT,
@IdContrato    INT,
@IdUsuario     INT,
@IdPedimentoComprobanteDetalle INT,

@PrecioUnitario FLOAT,
@DescripcionMercancia NVARCHAR(max),
@IdUnidadMedida INT,
@NumeroSerieMercancia NVARCHAR(200),
@Cantidad FLOAT,
@ImporteTotal FLOAT

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		   
		   if @NumeroSerieMercancia ='0'
		   SET @NumeroSerieMercancia=''

           UPDATE dbo.FI_PedimentoComprobanteDetalle 
		   SET IdUnidadMedida=@IdUnidadMedida,
           NumeroSerieMercancia=@NumeroSerieMercancia,
           DescripcionMercancia=@DescripcionMercancia,
           PrecioUnitario = @PrecioUnitario,
           Cantidad = @Cantidad,
		   ImporteTotal =@ImporteTotal
		   WHERE IdPedimentoComprobanteDetalle=@IdPedimentoComprobanteDetalle

		   SELECT 'SUCCESS' 
     END;

