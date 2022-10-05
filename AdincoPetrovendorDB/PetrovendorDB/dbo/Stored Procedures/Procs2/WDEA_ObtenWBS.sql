USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'WDEA_ObtenWBS'
)
    DROP PROCEDURE WDEA_ObtenWBS;
/****** Object:  StoredProcedure [dbo].[WDEA_ObtenWBS]    Script Date: 04/10/2022 12:47:36 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WDEA_ObtenWBS]
@IdUsuario int,
@IdContrato int
AS
BEGIN
	SELECT W.Id,W.WBS,W.CreadoEl,W.CreadoPor,W.IdContrato,W.Activo
	FROM WDEA_WBS W
	LEFT JOIN WDEA_WBSLineaPresupuesto WLP
		ON W.Id = WLP.IdWBS
		AND WLP.Activo = 1 
		AND WLP.IdContrato= @IdContrato
	WHERE 
	W.ACTIVO = 1
	AND WLP.Id IS NULL 
	AND W.IDCONTRATO = @IdContrato
	
END