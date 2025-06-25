use Petrovendor
go
DROP PROC IF EXISTS USP_SEL_S_Notificacion
go
CREATE PROC USP_SEL_S_Notificacion
--Creado por: David de la cruz
--Fecha: 10/06/2025
--Desc: Obtención de notificación para reenvío de correo (usando sdk)
@IdNotificacion int,
@IdUsuario int = null,
@IdContrato int = null
as
begin
	select top 1
	IdNotificacion,
	Para,
	Asunto,
	Mensaje,
	FechaProgramadaEnvio,
	Enviada,
	FechaEnvio,
	CreadoPor,
	CreadoEl,
	ModificadoPor,
	ModificadoEl,
	De,
	EN_MsjEnviado,
	CCO,
	'' as Modulo
	from Adinco..S_Notificacion
	where IdNotificacion = @IdNotificacion
end
