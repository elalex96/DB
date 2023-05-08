-- =============================================
-- Author:		Luis David
-- Create date: 21/04/2022
-- Description:	Se actualiza el aprobador de la SAS y se agrega a la bitácora
-- =============================================
CREATE PROC SAS_sp_CambiarAprobadorSAS
@IdSolicitudAceptacionPedido int,
@IdUsuario int,
@IdNuevoAprobador int,
@NombreNuevoAprobador varchar(300)
AS
BEGIN
DECLARE @IdTarea int = 0,
@NombreAntiguoAprobador varchar(300),
@IdOperacion int = 0,
@NombreUsuario varchar (300) = (SELECT NOMBRE FROM S_Usuario WHERE IdUsuario = @IdUsuario),
@IdEstatus int = 0;


			SELECT 
			 @IdTarea = T.IdTarea,
			 @NombreAntiguoAprobador = U.Nombre,
			 @IdOperacion = O.IdOperacion,
			 @IdEstatus = t.IdEstatus
			 FROM TA_Operacion O
			 JOIN TA_Tarea T 
				ON O.IdOperacion = T.IdOperacion
			 JOIN S_Usuario U
				ON T.IdAprobador = U.IdUsuario
			 JOIN TA_Estatus E
				ON T.IdEstatus = E.IdEstatus
			WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
			AND O.IdTipoOperacion=20		
			AND T.Activo=1
			ORDER BY T.NoSecuencia ASC 

	UPDATE TA_TAREA
	SET IDAPROBADOR = @IdNuevoAprobador
	WHERE IDTAREA = @IdTarea

	INSERT INTO TA_HistorialFlujoTarea
	(	Descripcion,		
		IdOperacion,		
		Fecha,
		IdEstadoFlujo) 
	VALUES
	(	CONCAT('El usuario ',@NombreUsuario,' actualizó al aprobador de la tarea No.',@IdTarea,'. Aprobador anterior: ', @NombreAntiguoAprobador,'- Nuevo Aprobador: ',@NombreNuevoAprobador),
		@IdOperacion,
		GETDATE(),
		@IdEstatus
	)

END