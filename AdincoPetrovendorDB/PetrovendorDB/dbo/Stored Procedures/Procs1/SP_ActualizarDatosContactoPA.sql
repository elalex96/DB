-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActualizarDatosContactoPA]
 @IdTipoContacto              int,
 @Nombres                     varchar(50),
 @Apellidos                   varchar(50),
 @Email                       varchar(50),
 @Telefono                    varchar(10),
 @IsPredeterminado            bit,
 @Titulo                      varchar(50),
 @Puesto                      varchar(50),
 @Celular_VENTAS              varchar(10),
 @IdContacto                  int,
 @IdProveedor                 int
AS
declare @CuentaPredeterminada bit
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	set @CuentaPredeterminada = (select IsPredeterminado from S_Contacto_PA 
	                             where IdContacto = @IdContacto and IsEliminado = 0)
								

	if @CuentaPredeterminada = @IsPredeterminado
	begin
	 update S_Contacto_PA
	 set 
	 IdTipoContacto = @IdTipoContacto,
     Nombres = @Nombres,
     Apellidos = @Apellidos,
     Email = @Email,
     Telefono = @Telefono,
     IsPredeterminado = @IsPredeterminado,
     Titulo = @Titulo,
     Puesto = @Puesto,
     Celular_VENTAS = @Celular_VENTAS
	 where IdContacto = @IdContacto
	end

	else
	begin
	declare @IdContactoPredeterminado int
	set @IdContactoPredeterminado = (select IdContacto from S_Contacto_PA 
	                                 where IsPredeterminado = 1 
								     and IdProveedor = @IdProveedor and IsEliminado = 0)

     update S_Contacto_PA --Cambio de estatus de contacto predeterminado
	 set 
     IsPredeterminado = @CuentaPredeterminada
	 where IdContacto = @IdContactoPredeterminado


     update S_Contacto_PA --Contacto a actualizar
	 set 
	 IdTipoContacto = @IdTipoContacto,
     Nombres = @Nombres,
     Apellidos = @Apellidos,
     Email = @Email,
     Telefono = @Telefono,
     IsPredeterminado = @IsPredeterminado,
     Titulo = @Titulo,
     Puesto = @Puesto,
     Celular_VENTAS = @Celular_VENTAS
	 where IdContacto = @IdContacto



	end

   


END 

