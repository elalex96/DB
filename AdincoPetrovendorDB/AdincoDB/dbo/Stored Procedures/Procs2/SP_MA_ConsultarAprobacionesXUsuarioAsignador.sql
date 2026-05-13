-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 07-03-18
-- Description:	 Consulta APROBACIÓNES POR ASIGNADOR
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_ConsultarAprobacionesXUsuarioAsignador] 
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdContrato	INT=0,
	@IdSubcontratista INT =0,
	@FechaRegistro DATETIME= '25-01-2017 00:00'	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	  SELECT O.IdOperacion, O.IdDocumento, E.Nombre AS NombreEstatus, T.Nombre AS NombreOperacion, O.ComentarioGral, F.IdTipoOperacion,O.FechaRegistro, P.Prioridad,V.Vigencia,U.Nombre, OD.IdOperacionDetalle
	  FROM dbo.MA_Operacion O
	  INNER JOIN dbo.MA_OperacionDetalle AS OD ON OD.IdOperacion=O.IdOperacion
	  INNER JOIN dbo.MA_Flujo AS F ON F.IdFlujo = O.IdFlujo
	  INNER JOIN dbo.MA_TipoOperacion AS T ON T.IdTipoOperacion=F.IdTipoOperacion
	  INNER JOIN dbo.MA_Prioridad AS P ON P.IdPrioridad=O.IdPrioridad
	  INNER JOIN dbo.MA_Vigencia AS V ON V.IdVigencia= O.IdVigencia
	  INNER JOIN dbo.MA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	  INNER JOIN dbo.AP_Usuario AS U ON U.UsuarioID=O.IdUsuarioRegistro
	  WHERE O.IdUsuarioRegistro=@IdUsuario AND O.IdContrato=@IdContrato
	  ORDER BY O.IdOperacion DESC
	  
 END






