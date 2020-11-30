-- sp_SC_ConsultaServicio 7
create proc [dbo].[sp_SC_ConsultaMaterialServicio]
@pIdSubContrato int
As

	select serv.IdServicio,
		serv.NombreServicio
	from SC_Materiales mat
	inner join CO_Servicio serv on serv.IdServicio = mat.IdServicio
	where mat.IdSubContrato = @pIdSubContrato
	group by serv.IdServicio,
		serv.NombreServicio

