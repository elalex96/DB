
-- =============================================
-- Author:		Daniel AC
-- Create date: 29-03-17
-- Description:	Regresa la información de una Tarea Flujo 				
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 10-01-2018
-- Description:	Regresa la información de una Tarea Flujo + Parametros de orden de compra IdPedido				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarDetalleFlujoTarea] 
	-- Add the parameters for the stored procedure here
	 @IdOperacion int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  SELECT  FT.Nombre,TAE.Nombre AS EstadoOperacion, TOO.IdEstadoFlujo, TFT.Nombre AS TipoFlujo,EFT.NombreEstado,TOO.IdAsignador,U.Nombre AS [Nombre Asignador], TOO.FechaRegistro, TOO.Descripcion, TP.Nombre, TV.DiaVencimiento, TOO.IdEstatusOperacion, U.Correo AS [Correo Asignador], TCC.Descripcion, TTO.NombreOperacion, TOO.IdDocumento,TOO.IdTipoOperacion, ISNULL(PS.IdPedido,0) AS IdPedido
	  FROM TA_Operacion AS TOO
	  INNER JOIN TA_FlujoTarea AS FT ON FT.IdFlujoTarea = TOO.IdFlujoTarea
	  INNER JOIN TA_TipoFlujoTarea AS TFT ON TFT.IdTipoFlujoTarea = FT.IdTipoFlujo
	  INNER JOIN TA_EstadoFlujoTarea AS EFT ON TOO.IdEstadoFlujo =  EFT.IdEstado
	  INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
	  INNER JOIN TA_Estatus AS TAE ON TAE.IdEstatus = TOO.IdEstatusOperacion
	  INNER JOIN S_Usuario AS U ON U.IdUsuario= TOO.IdAsignador
	  INNER JOIN TA_Prioridad AS TP ON TP.IdPrioridad = TOO.IdPrioridad
	  INNER JOIN TA_Vencimiento AS TV ON TV.IdVencimiento = TOO.IdVigencia
	  LEFT JOIN TA_ComentariosTareaCancelada AS TCC ON TCC.IdOperacion = TOO.IdOperacion
	  LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador= TOO.IdDocumento AND TOO.IdProveedor= PS.IdProveedorCliente AND PS.IdTipoPedido=1 -- ORDEN DE COMPRA DIRECTA 
	  WHERE  TOO.IdOperacion = @IdOperacion
	 
END


