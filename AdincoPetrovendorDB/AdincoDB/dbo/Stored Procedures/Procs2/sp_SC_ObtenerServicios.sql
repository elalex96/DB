
-- sp_SC_ObtenerServicios 1,1
Create Proc [dbo].[sp_SC_ObtenerServicios]
@pIdContratista int,
@pIdSubContrato int
As

	select 
			serv.IdServicio,
			serv.IdContrato,
			serv.NombreServicio,
			serv.IdUnidad,
			serv.IdUsuario,
			serv.FecMovto,
			serv.Activo,
			serv.CreadoPor
	from CO_Servicio serv
	inner join CO_Contrato co on co.IdContrato = serv.IdContrato
	where co.IdContratista = @pIdContratista and
	serv.Activo = 1
	order by NombreServicio
