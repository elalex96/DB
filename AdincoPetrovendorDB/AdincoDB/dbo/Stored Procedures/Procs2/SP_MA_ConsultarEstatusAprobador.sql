-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 05-01-18
-- Description:	 Consultar estatus de un aprobador 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_ConsultarEstatusAprobador]-- 2,6,3,3,0,NULL
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdOperacion INT,
	@IdOperacionDetalle INT,
	@IdContrato	INT,		
	@IdSubcontratista INT =0,
	@FechaRegistro DATETIME= '25-01-2017 00:00'	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	  SELECT 	 
	  OD.IdOperacionDetalle, OD.IdAprobador, OD.IdEstatus, OD.FechaCambioEstatus, OD.Comentario, OD.NoSecuencia, e.Nombre AS EstatusOD, U.UsuarioID, U.Nombre
	  FROM dbo.MA_Operacion O	
	  INNER JOIN dbo.MA_OperacionDetalle OD ON OD.IdOperacion=O.IdOperacion	  
	  INNER JOIN dbo.MA_Estatus AS E ON E.IdEstatus = OD.IdEstatus
	  INNER JOIN dbo.AP_Usuario AS U ON u.UsuarioID=OD.IdAprobador
	  WHERE O.IdOperacion= @IdOperacion AND O.IdContrato=@IdContrato AND OD.IdOperacionDetalle=@IdOperacionDetalle AND OD.IdAprobador=@IdUsuario
	  
 END






