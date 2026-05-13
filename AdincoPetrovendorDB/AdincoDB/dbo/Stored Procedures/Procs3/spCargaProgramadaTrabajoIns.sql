CREATE proc [dbo].[spCargaProgramadaTrabajoIns]
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
	--declare	@IdCargaProgramadaTrabajo int
	--select @IdCargaProgramadaTrabajo = isnull(max(IdCargaProgramadaTrabajo),0)+1 from CargaProgramadaTrabajo
	--DECLARE @MESCARGA DATE = CAST(('01-' + MONTH(GETDATE()) + '-' + YEAR(GETDATE())) AS date);
	DECLARE @MESCARGA DATE = CONVERT(date,(CAST(YEAR(GETDATE()) AS nvarchar) + '-' + CAST(MONTH(GETDATE()) AS nvarchar) + '-01'));

	insert into CO_CargaProgramadaTrabajo
				(
					Actividad,
					Unidad,
					Cantidad,
					UnidadesActividad,
					UnidadesTrabajo,
					IdContrato,
					Fecha,
					Estatus,
					IdUsuario,
					FechaModificacion,
					MesCarga,
					Activo
				)
			values
				(
					@Actividad,
					@Unidad,
					@Cantidad,
					@UnidadesActividad,
					@UnidadesTrabajo,
					@IdContrato,
					Getdate(),
					@Estatus,
					@IdUsuario,
					GETDATE(),
					@MESCARGA,
					1
				);
end