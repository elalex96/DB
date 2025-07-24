USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..Carso_sp_EnviaCorreosComparativasPendientes') IS NOT NULL
BEGIN
DROP PROCEDURE Carso_sp_EnviaCorreosComparativasPendientes;
END
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 11/07/2025
-- Description:	se agrega una consulta para retornar los datos de aprobaciones de solicitud de pedido para adinco app para enviarlas por sdk
-- =============================================
CREATE PROCEDURE [dbo].[Carso_sp_EnviaCorreosComparativasPendientes]
@ComparativaHtml varchar(max)
AS
BEGIN

DECLARE @pIdNotificacion int,
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
	@HTML,	
	CD.Idusuario 
FROM Carso_Comparativa_Destinatarios CD (NOLOCK)
where CD.Activo = 1;

SELECT
		U.Correo,		
		'Resultado de Procesamiento de Comparativas' AS Asunto,
		REPLACE(@HTML,'##NombreUsuario##',u.Nombre) AS Mensaje
		FROM #CorreosPendientes AS CP
			JOIN S_Usuario U (NOLOCK)
			ON CP.IdUsuario = U.IdUsuario

END;
