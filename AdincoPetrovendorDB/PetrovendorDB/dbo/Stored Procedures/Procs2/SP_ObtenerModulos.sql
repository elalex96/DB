-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ObtenerModulos]

@IdPerfil int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	 

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--select M.StringModuloId from PerfilModulo as PM inner join Modulo as M on PM.IdModulo = M.IdModulo where PM.IdPerfil != @IdPerfil
          

		  DECLARE @PerfilModuloExistente int

		  SET @PerfilModuloExistente =(
		  SELECT COUNT(PM.IdPerfilModulo)
		  FROM PerfilModulo PM
		  WHERE PM.IdPerfil = @IdPerfil
		  )

		  IF @PerfilModuloExistente > 0
		  BEGIN

		  	select StringModuloId from OcultarStrings(@IdPerfil)
			except
			select StringModuloId from MostrarStrings(@IdPerfil)

		  END
	 


     

END


