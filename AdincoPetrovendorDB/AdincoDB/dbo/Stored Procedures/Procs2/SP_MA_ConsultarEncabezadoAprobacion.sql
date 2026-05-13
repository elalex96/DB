-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 05-01-18
-- Description:	 Actualiza el Estatus de de la APROBACIÓN DE LA OPERACIÓN X 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_ConsultarEncabezadoAprobacion]  
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdOperacion INT,
	@IdContrato	INT,		
	@IdSubcontratista INT =0,
	@FechaRegistro DATETIME= '25-01-2017 00:00'	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	  SELECT 
	  O.IdOperacion,
	  O.IdDocumento,
	  O.IdFlujo, 
	  O.IdEstatusOperacion,	 
	  O.IdVigencia,
	  O.IdPrioridad,
	  O.FechaFinalizacion,
	  O.IsFechaFinalizacion,
	  F.IdTipoOperacion,
	  E.Nombre AS NombreEstatus,
	  T.Nombre AS NombreOperacion, 
	  O.ComentarioGral, 
	  O.FechaRegistro, 
	  P.Prioridad,
	  U.Nombre,
	  U.UsuarioID,
	  U.Usuario,
	  F.IdTipoFlujo,
	  TF.TipoFlujo,
	  V.Vigencia
	  FROM dbo.MA_Operacion O	  
	  INNER JOIN dbo.MA_Flujo AS F ON F.IdFlujo = O.IdFlujo
	  INNER JOIN dbo.MA_TipoOperacion AS T ON T.IdTipoOperacion=F.IdTipoOperacion
	  INNER JOIN dbo.MA_Prioridad AS P ON P.IdPrioridad=O.IdPrioridad
	  INNER JOIN dbo.MA_Vigencia AS V ON V.IdVigencia= O.IdVigencia
	  INNER JOIN dbo.MA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	  INNER JOIN dbo.AP_Usuario AS U ON u.UsuarioID=O.IdUsuarioRegistro
	  INNER JOIN dbo.MA_TipoFlujo AS TF ON TF.IdTipoFlujo=F.IdTipoFlujo
	  WHERE O.IdOperacion=@IdOperacion  AND O.IdContrato=@IdContrato
	  
 END






