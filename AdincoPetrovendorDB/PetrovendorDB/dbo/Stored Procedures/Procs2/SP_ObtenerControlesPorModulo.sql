-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ObtenerControlesPorModulo]
@IdPerfil int
--@IdModulo int
AS
BEGIN



	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PMC.IdPerfilModulo, PM.IdPerfil, PM.IdModulo, PMC.IdControl, C.NombreControl
    FROM PerfilModuloControl as PMC inner join PerfilModulo as PM on PMC.IdPerfilModulo = PM.IdPerfilModulo 
    inner join [dbo].[Control] as C on PMC.IdControl = C.IdControl
    WHERE PM.IdPerfil = @IdPerfil and PMC.Activo = 0
END

