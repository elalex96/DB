-- sp_SC_ConsultaServicio 7
create proc [dbo].[sp_SC_ConsultaMaterialServicio]
@pIdSubContrato int
As

	select CO_Servicio.IdServicio,
		CO_Servicio.NombreServicio
	from SC_Materiales (NOLOCK)
	inner join CO_Servicio (NOLOCK) on SC_Materiales.IdServicio = CO_Servicio.IdServicio 
	where SC_Materiales.IdSubContrato = @pIdSubContrato
	group by CO_Servicio.IdServicio,
		CO_Servicio.NombreServicio

GO


