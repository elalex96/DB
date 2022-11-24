-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2019
-- Description:	Validar exista un flujo de aprobación de factura 
-- =============================================
CREATE   PROCEDURE  [dbo].[SP_TA_ValidarExistaFlujoAprobacionFactura] 
	-- Add the parameters for the stored procedure here				
	@IdProveedor INT,
	@IdUsuario INT,
	@IdAceptacionPedido INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- CONSULTAR EL FLUJO DE APROBACIÓN 

	DECLARE @IdFlujoAprobacion int 
	SELECT @IdFlujoAprobacion= FT.IdFlujoTarea
	FROM MM_AceptacionFactura AS AF
	INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
	INNER JOIN MM_Pedido   AS P on P.IdPedido= AP.IdPedido 
	INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras
	INNER JOIN TA_FlujoTarea AS FT ON FT.IdProveedor =P.IdProveedorCompras
	WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND FT.IdTipoOperacion = 10 ---> APROBACIÓN FACTURA 
	AND FT.Activo=1 AND FT.Predeterminado=1

    -- Agregar Operación Si IdFlujoTarea =  0 Es una operación que no tiene flujo de tarea	
	SELECT ISNULL(@IdFlujoAprobacion,0) AS IdFlujoAprobacion

END

