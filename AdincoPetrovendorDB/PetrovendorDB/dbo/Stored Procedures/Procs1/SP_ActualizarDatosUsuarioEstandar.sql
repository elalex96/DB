-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[SP_ActualizarDatosUsuarioEstandar]

@IdUsuario int,
@Nombre varchar(100),
@Correo varchar(50),
@NombreTipoUsuario varchar(50),
@Telefono varchar(50),
@Activo bit

AS
BEGIN

declare @IdTipoUsuario int = (select TU.IdTipoUsuario from S_TipoUsuario as TU where TU.NombreTipoUsuario = @NombreTipoUsuario)


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    update S_Usuario set 
	Nombre = @Nombre, 
	Correo = @Correo, 
	IdTipoUsuario = @IdTipoUsuario ,
	Telefono = @Telefono,  
	Activo = @Activo	
	where IdUsuario = @IdUsuario 

	
END

