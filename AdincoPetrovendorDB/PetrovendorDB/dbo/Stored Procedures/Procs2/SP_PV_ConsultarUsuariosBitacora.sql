-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarUsuariosBitacora]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT US.IdUsuario, US.Nombre, US.Correo, US.FechaRegistro, UST.NombreTipoUsuario FROM S_Usuario AS US
	INNER JOIN S_TipoUsuario AS UST ON UST.IdTipoUsuario = US.IdTipoUsuario


END

