use Adinco

go

if not exists (select * from sys.tables where name  = 'CargaProgramadaTrabajo')
begin
	create table CargaProgramadaTrabajo
	(
		IdCargaProgramadaTrabajo	int,
		Actividad					varchar(200),
		Unidad						varchar(100),
		Cantidad					decimal (10,2),
		UnidadesActividad			decimal (10,2),
		UnidadesTrabajo				decimal (10,2),
		Estatus						varchar(100),
		IdContrato					int,
		Fecha						smalldatetime,
		IdUsuario					int
		constraint					PK_CargaProgramadaTrabajo				primary key (IdCargaProgramadaTrabajo)
		constraint					FK_CargaProgramadaTrabajo_AP_Usuario	foreign key (IdUsuario)					references AP_Usuario(UsuarioID)
	)
end

--Se agregaron columnas
