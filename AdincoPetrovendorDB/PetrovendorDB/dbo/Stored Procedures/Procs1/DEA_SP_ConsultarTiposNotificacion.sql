-- =============================================
-- Author:	Daniel AC
-- Create date: <20/08/2019>
-- Description:	<Consulta de las PR>
-- =============================================
CREATE  PROCEDURE [dbo].[DEA_SP_ConsultarTiposNotificacion] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT TipoNotificacion, Detalle FROM dbo.DEA_TipoNotificiacion 
	 WHERE Activo=1
	 ORDER BY Detalle ASC
	 

END
