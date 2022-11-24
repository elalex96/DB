
CREATE proc [dbo].[sp_S_Usuario_Cmb]
as
begin
		select	IdUsuario,
				Nombre
		from	S_Usuario
		where	Activo = 1
		and		isnull(IsEliminado,0) = 0
		order by Nombre asc 
end