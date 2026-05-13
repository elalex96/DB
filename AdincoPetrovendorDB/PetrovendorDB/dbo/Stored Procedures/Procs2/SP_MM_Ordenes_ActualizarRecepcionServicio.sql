-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Actualizar confirmación de Surtido de pedido detalle
-- =============================================
--**************************************************************
-- Modified:      <Jose Roman>									
-- Updated date: <09/01/2018>									
-- Description: <Se agrega el guardado de la firma electronica y parametros de contrato>			
--**************************************************************
CREATE PROCEDURE [dbo].[SP_MM_Ordenes_ActualizarRecepcionServicio]
	-- Add the parameters for the stored procedure here
	@IdPedido int,
	@IdUsuario INT,
	@RecepcionServicio INT,
	@Firma NVARCHAR(max),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
  /*---------------------------------------------------------------*/ 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	   UPDATE MM_Pedido
	   SET RecepcionServicio = @RecepcionServicio, 
	   FechaRecepcionServicio = GETDATE(),
	   IdUsuarioRecepcionServicio = @IdUsuario,
	   IdFirma = @Firma
	   WHERE IdPedido = @IdPedido

	   SELECT IdProveedorCompras AS RESPONSE FROM dbo.MM_Pedido WHERE IdPedido = @IdPedido
END


