CREATE proc p_AP_EsAdministrador 
@idRol int,
@usuarioDef varchar(200)
as
begin
	declare @rol varchar(200) , @descipcion varchar(200);
	select 
		@rol = Rol,
		@descipcion= Descripción from AP_Rol where IdRol = @idRol
		
		if @rol = 'Administrador' or @descipcion = 'Administrador de la plataforma ADINCO' or @rol = 'Root' or  @descipcion= 'Super-Usuario' or @usuarioDef = 'daniel.moreno@adinco.mx' OR @usuarioDef ='administrador@smps-adinco.com' OR @usuarioDef ='mg@smps-sp.com'
		begin
			select 1 as 'UsuarioADM'
		end
		else
		begin
			select 0 as 'UsuarioADM'
		end
end

