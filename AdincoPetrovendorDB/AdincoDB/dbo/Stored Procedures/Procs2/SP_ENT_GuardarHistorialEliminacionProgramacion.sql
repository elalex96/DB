--USE [Adinco]
--IF EXISTS
--(
--    SELECT 1
--    FROM dbo.sysobjects
--    WHERE name = 'SP_ENT_GuardarHistorialEliminacionProgramacion'
--)
--    DROP PROCEDURE SP_ENT_GuardarHistorialEliminacionProgramacion;   
	
--GO
--/****** Object:  StoredProcedure [dbo].[EN_sp_EliminaProgramacion]    Script Date: 07/06/2023 02:47:04 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-- =============================================
-- Author: Daniel AC
-- Create date: 07-06-2023
-- Description: Agregar historial de los entregables programados eliminados
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENT_GuardarHistorialEliminacionProgramacion]
@IdContrato INT,
@IdUsuario INT,
@ProgramacionesIds NVARCHAR(MAX),
@ProgramacionesEntContratoIds NVARCHAR(MAX),
@Comentario VARCHAR(MAX)
AS
BEGIN
	-- CADA ENTREGABLE INSTANCIA Y CONTRATO ENTREGABLE ID DEBE VENIR EN EL MISMO ORDEN DE LA LISTA DE @Programaciones
	DECLARE @BitacoraEliminacionProgramacionId INT  = 0 
	CREATE TABLE #Historial(Id INT IDENTITY(1,1) PRIMARY KEY,EntregableInstanciaId INT)
	CREATE TABLE #HistorialEntContrato(Id INT IDENTITY(1,1) PRIMARY KEY, ContratoEntId INT)


	INSERT INTO #Historial(EntregableInstanciaId)
	SELECT Item 
	FROM dbo.DelimitedSplit(@ProgramacionesIds,',')

	INSERT INTO #HistorialEntContrato(ContratoEntId)
	SELECT Item 
	FROM dbo.DelimitedSplit(@ProgramacionesEntContratoIds,',')


	INSERT INTO ENT_BitacoraEliminacionInstancia(
	Comentario,	
	ContratoId,
	UsuarioId,
	FechaEliminacion)
	VALUES(
	@Comentario,
	@IdContrato,
	@IdUsuario,
	GETDATE()
	)

	SET @BitacoraEliminacionProgramacionId = (SELECT SCOPE_IDENTITY())

	INSERT INTO ENT_BitacoraEliminacionProgramacionDetalle(
	BitacoraEliminacionProgramacionId, 
	InstanciaEntregableId, 
	ContratoEntregableId)

	SELECT 
	@BitacoraEliminacionProgramacionId,
	H.EntregableInstanciaId, 
	HC.ContratoEntId
	FROM #Historial H
	JOIN #HistorialEntContrato HC 
	ON H.Id = HC.Id
		

END