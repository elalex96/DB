-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017 - UPDATE 13/08/2017
-- Description:	Permite agregar un condicion a un flujo de tareas
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ConsultarFlujoPedidoPedido] 
	-- Add the parameters for the stored procedure here
 @IdProveedor int 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	SELECT 
	ft.IdFlujoTarea,
	ft.Nombre AS Nombreflujo,
	Descripcion,
	NombreCondicion,
	ValorInicial,
	ValorFinal,
	TF.Nombre AS TipoFlujo,
--	U.Nombre AS Aprobador,
--	U.Correo,
--	AP.NoSecuencia,
	ISNULL(ft.Predeterminado,0) AS Predeterminado
	FROM
	TA_FlujoTarea AS FT
	INNER JOIN TA_TipoOperacion AS OPE ON OPE.IdTipoOperacion= FT.IdTipoOperacion
	INNER JOIN TA_FlujoTareaCondicion AS CO ON CO.IdFlujoTarea = FT.IdFlujoTarea
	INNER JOIN TA_TipoFlujoTarea AS TF ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
	INNER JOIN TA_FlujoTareaConstante AS FC ON FC.IdConstante = CO.IdConstanteCondicion
---	INNER JOIN TA_Aprobador AS AP ON AP.IdFlujoTarea = FT.IdFlujoTarea 
	---INNER JOIN S_Usuario AS U ON U.IdUsuario = AP.IdUsuario
	WHERE OPE.IdTipoOperacion=7 AND (FT.Eliminado =  0 OR FT.Eliminado IS NULL) AND FT.IdProveedor= @IdProveedor


	--SELECT 
	--ft.IdFlujoTarea,
	--ft.Nombre AS Nombreflujo,
	--Descripcion,
	--NombreCondicion,
	--ValorInicial,
	--ValorFinal,
	--TF.Nombre AS TipoFlujo,
	--U.Nombre AS Aprobador,
	--U.Correo,
	--AP.NoSecuencia,
	--ISNULL(ft.Predeterminado,0) AS Predeterminado
	--FROM
	--TA_FlujoTarea AS FT
	--INNER JOIN TA_TipoOperacion AS OPE ON OPE.IdTipoOperacion= FT.IdTipoOperacion
	--INNER JOIN TA_FlujoTareaCondicion AS CO ON CO.IdFlujoTarea = FT.IdFlujoTarea
	--INNER JOIN TA_TipoFlujoTarea AS TF ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
	--INNER JOIN TA_FlujoTareaConstante AS FC ON FC.IdConstante = CO.IdConstanteCondicion
	--INNER JOIN TA_Aprobador AS AP ON AP.IdFlujoTarea = FT.IdFlujoTarea 
	--INNER JOIN S_Usuario AS U ON U.IdUsuario = AP.IdUsuario
	--WHERE OPE.IdTipoOperacion=7 AND (FT.Eliminado =  0 OR FT.Eliminado IS NULL) AND FT.IdProveedor= @IdProveedor
END

