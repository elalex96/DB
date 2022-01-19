USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[sp_EN_ExtraeCalendarioRegulador]    Script Date: 18/01/2022 04:09:02 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 2022/18/01
-- =============================================
ALTER PROCEDURE [dbo].[sp_EN_ExtraeCalendarioRegulador]--[sp_EN_ExtraeCalendarioRegulador] 3,10061
	@idContrato INT,
	@idUsuario INT
AS
BEGIN

	SET NOCOUNT ON;

	Select 
		0 as IdRegulador,
		'Calendario Default' as Regulador
	UNION ALL
	Select 
		10001 as IdRegulador,
		'Todos los reguladores' as Regulador
	UNION ALL 
	SELECT 
		R.IdRegulador as IdRegulador,
		R.Regulador as Regulador 
	FROM AP_CalendarioExcepciones CE
	JOIN CO_Regulador R 
		ON CE.IdRegulador=R.IdRegulador
	Group by R.IdRegulador,
			R.Regulador,
			R.NombreRegulador;

END
