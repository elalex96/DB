USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Carso_sp_EnviaCorreosComparativasPendientes'
)
    DROP PROCEDURE Carso_sp_EnviaCorreosComparativasPendientes;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Carso_sp_EnviaCorreosComparativasPendientes]
@ComparativaHtml varchar(max)
AS
BEGIN
DECLARE
@pIdNotificacion int,
@counterComparativas int = 0,
@counterWhile int = 1, 
@HTML varchar(max) = (SELECT HTML FROM TA_Correo WHERE Asunto = 'Resultado de Procesamiento de Comparativas');
SET @HTML = (replace(@HTML,'##Detalle##',@ComparativaHtml));
SET @HTML = (replace(@HTML,'##YEAR_ACTUAL##',CAST(YEAR(getdate()) as varchar(10))))
DROP TABLE IF EXISTS #CorreosPendientes
CREATE TABLE #CorreosPendientes(
	Id int primary key not null identity (1,1),
	CuerpoCorreo VARCHAR(MAX),
	IdUsuario INT
)
insert into #CorreosPendientes(
	CuerpoCorreo,IdUsuario
)
SELECT 
	@HTML,	CD.Idusuario 
FROM Carso_Comparativa_Destinatarios CD (NOLOCK)
where CD.Activo = 1;

SET @counterComparativas = (SELECT COUNT(1) FROM #CorreosPendientes);

WHILE @counterWhile <= @counterComparativas
	BEGIN
		SELECT @pIdNotificacion = isnull(max(IdNotificacion),0) + 1
		FROM Adinco..S_Notificacion (NOLOCK)

		INSERT INTO Adinco..S_Notificacion(
		IdNotificacion,		Para,			Asunto,			
		Mensaje,			FechaProgramadaEnvio,
		Enviada,			FechaEnvio,		CreadoPor,		CreadoEl,		ModificadoPor,
		ModificadoEl,		De,				EN_MsjEnviado)
		SELECT
		@pIdNotificacion ,	U.Correo,		'Resultado de Procesamiento de Comparativas',
		REPLACE(@HTML,'##NombreUsuario##',u.Nombre),	getdate(),
		0,					null,			1,getdate(),null,
		null,				'notificaciones@adinco.mx',null
		FROM #CorreosPendientes AS CP
			JOIN S_Usuario U
			ON CP.IdUsuario = U.IdUsuario
		WHERE CP.Id = @counterWhile
		SET @counterWhile = (@counterWhile + 1);

	END;

END;
