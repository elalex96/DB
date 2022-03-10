USE ADINCO
GO
DROP PROCEDURE IF EXISTS EN_sp_GuardaBitacoraReporteSASISOPA
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 10/Marzo/2022
-- Description:	Se guardan las solicitudes de documentos de exportación sasisopa
-- =============================================
GO
CREATE PROC EN_sp_GuardaBitacoraReporteSASISOPA
@IdUsuario int,
@IdContrato int,
@FechaInicial datetime,
@FechaFinal datetime,
@Server varchar(300)
AS
BEGIN 
	INSERT INTO EN_Documentos_BitacoraReporteSASISOPA(
	IdUsuario,		IdContrato,		FechaInicial,
	FechaFinal,		FechaCreacion,	Procesado,
	Server) VALUES
	(@IdUsuario,	@IdContrato,	@FechaInicial,
	@FechaFinal,	GETDATE(),		0,
	@Server
	)
END