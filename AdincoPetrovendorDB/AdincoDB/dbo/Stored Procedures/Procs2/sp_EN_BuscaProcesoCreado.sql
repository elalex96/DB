-- =============================================
-- Author:    Reyna Olvera
-- Create date: 20200319
-- Description:  BUSCA PROCESOS
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_BuscaProcesoCreado] 
@idContrato int,
@idUsuario int,
@idProceso int,
@IdInstalacion int
AS  
BEGIN
  SET NOCOUNT ON;
  DECLARE @TieneInstalacion	INT	=	0,	@NombreProceso VARCHAR(MAX),	@Descripcion VARCHAR(MAX), @idTipoProceso INT = 0, @IsProcesoEvento BIT,@IsSerie BIT;

    SELECT	@TieneInstalacion	=	
	COUNT(1)-- 1 ES PROCESO PARA COPIAR 
    FROM	
		dbo.EN_Procesos
    WHERE	IdProceso	=	@idProceso
		AND	IdInstalacion	IS	NULL;


    SELECT	@NombreProceso	=	NombreProceso,--proceso para pruebas con nuevas actividades
			@Descripcion	=	Descripcion,
			@IsProcesoEvento	=	IsProcesoEvento,
			@IsSerie	=	IsSerie
    FROM	
		dbo.EN_Procesos
    WHERE	IdProceso	=	@idProceso
    AND	IdInstalacion	IS	NULL;


	SELECT P.IdProceso
	FROM	
			dbo.EN_Procesos	P
		WHERE	IdInstalacion	IS	NOT	NULL
		AND	NombreProceso	Like	@NombreProceso	+	'%' 
		AND	IdInstalacion	=	@IdInstalacion
		AND	P.Activo	=	1
		AND P.IsProcesoEvento	=	@IsProcesoEvento
		AND P.IsSerie	=	@IsSerie

END

