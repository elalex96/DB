-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ObtenerControlesPorModulo]
@IdPerfil int
--@IdModulo int
AS
BEGIN



	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select PMC.IdPerfilModulo, PM.IdModulo, PMC.IdControl from 
	PerfilModuloControl as PMC 
	inner join PerfilModulo as PM on PMC.IdPerfilModulo = PM.IdPerfilModulo 
	where PM.IdPerfil = @IdPerfil 
END

