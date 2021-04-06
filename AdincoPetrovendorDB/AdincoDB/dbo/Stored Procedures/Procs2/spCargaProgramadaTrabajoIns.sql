if exists (select * from sys.procedures cedures where name = 'spCargaProgramadaTrabajoIns')
begin
	drop proc spCargaProgramadaTrabajoIns
end

go

create proc spCargaProgramadaTrabajoIns
(
	@Actividad			varchar(200),
	@Unidad				varchar(100),
	@Cantidad			decimal(10,2),
	@UnidadesActividad	decimal(10,2),
	@UnidadesTrabajo	decimal(10,2),
	@Estatus			varchar(100),
	@IdContrato			int,
	@IdUsuario			int
)
as
begin
	declare	@IdCargaProgramadaTrabajo int
	select @IdCargaProgramadaTrabajo = isnull(max(IdCargaProgramadaTrabajo),0)+1 from CargaProgramadaTrabajo

	insert into CargaProgramadaTrabajo
				(
					IdCargaProgramadaTrabajo,
					Actividad,
					Unidad,
					Cantidad,
					UnidadesActividad,
					UnidadesTrabajo,
					IdContrato,
					Fecha,
					Estatus,
					IdUsuario
				)
			values
				(
					@IdCargaProgramadaTrabajo,
					@Actividad,
					@Unidad,
					@Cantidad,
					@UnidadesActividad,
					@UnidadesTrabajo,
					@IdContrato,
					Getdate(),
					@Estatus,
					@IdUsuario
				)
end
