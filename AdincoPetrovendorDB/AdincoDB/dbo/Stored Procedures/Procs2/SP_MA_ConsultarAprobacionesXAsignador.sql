-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 05-01-18
-- Description:	 Actualiza el Estatus de de la APROBACIÓN DE LA OPERACIÓN X 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_ConsultarAprobacionesXAsignador] 
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
	 
	  SELECT O.IdOperacion, O.IdDocumento, E.Nombre AS NombreEstatus, T.Nombre AS NombreOperacion, O.ComentarioGral, F.IdTipoOperacion,O.FechaRegistro, P.Prioridad
	  FROM dbo.MA_Operacion O	  
	  INNER JOIN dbo.MA_Flujo AS F ON F.IdFlujo = O.IdFlujo
	  INNER JOIN dbo.MA_TipoOperacion AS T ON T.IdTipoOperacion=F.IdTipoOperacion
	  INNER JOIN dbo.MA_Prioridad AS P ON P.IdPrioridad=O.IdPrioridad
	  INNER JOIN dbo.MA_Vigencia AS V ON V.IdVigencia= O.IdVigencia
	  INNER JOIN dbo.MA_Estatus AS E ON E.IdEstatus = O.IdEstatusFlujo
	  WHERE O.IdUsuarioRegistro=@IdUsuario
	  
 END






