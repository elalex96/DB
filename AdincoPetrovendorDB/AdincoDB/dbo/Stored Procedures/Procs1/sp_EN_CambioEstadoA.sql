-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/04/2018
-- Description:solo cambia el estatus para la instancia 
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_CambioEstadoA]
	-- Add the parameters for the stored procedure here
	@idUsuario int,
	@idContrato int,
	@idInstanciaEntregable int,
	@Estatus int

AS
BEGIN

	SET NOCOUNT ON;

	--Cuando esta en revision y si es aceptado pasara a aprobación
	if(@Estatus=10003)
    begin
		Update EN_InstanciasEntregable
		Set Estatus =@Estatus,FechaReviso=GetDate()
		where idInstanciaEntregable=@idInstanciaEntregable 
	end
	--Cuando esta en aprobación y si es aceptado pasara a final
	if(@Estatus=10004)
	begin
	Update EN_InstanciasEntregable
		Set Estatus =@Estatus,FechaAprobo=GetDate()
		where idInstanciaEntregable=@idInstanciaEntregable 
	end
	--Cuando es rechazado pasara a correccion para qur el usuario pueda corregir errores
		if(@Estatus=10005)
	begin
	Update EN_InstanciasEntregable
		Set Estatus =@Estatus
		where idInstanciaEntregable=@idInstanciaEntregable 
	end

	-- cuandon se encuentran en la pagina RevisionAprobacionUsuario en el apartado de "TODOS" y dan en "ACEPTAR" alguna revision o aprobacion
	--solo manda el numero 1 para saber en que estatus esta originalmente la instancia entregable y poder avanzar al estatus que sigue
	if(@Estatus=1)
	Begin

	declare @EstadoPCambio int;
	--Busca el es estatus actual de la instancia
	Select @EstadoPCambio= Estatus From EN_InstanciasEntregable where idInstanciaEntregable=@idInstanciaEntregable 
		if (@EstadoPCambio=10002)
		begin
		--Si esta en revision pasa a aprobacion
			Update EN_InstanciasEntregable
		Set Estatus =10003,FechaReviso=GetDate()
		where idInstanciaEntregable=@idInstanciaEntregable 

		end
		--si esta en aprobacion pasa a final
		if (@EstadoPCambio=10003)
		begin

			Update EN_InstanciasEntregable
		Set Estatus =10004,FechaAprobo=GetDate()
		where idInstanciaEntregable=@idInstanciaEntregable 

		end

	End
END


