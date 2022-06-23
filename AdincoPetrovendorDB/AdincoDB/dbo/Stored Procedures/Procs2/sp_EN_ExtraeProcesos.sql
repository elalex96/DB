USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[sp_EN_ExtraeProcesos]    Script Date: 21/06/2022 02:42:32 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama las rondas
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/06/2022
-- Description:	Agregado del campo de la etapa
-- =============================================
ALTER PROCEDURE [dbo].[sp_EN_ExtraeProcesos]--3,10061
	@idContrato INT,
	@idUsuario INT
	--@IdContratoCb INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT p.IdProceso,
	CASE Isnull(clave,'')
		WHEN  ''
		THEN NombreProceso
		ELSE 
	clave +' '+NombreProceso
	END AS NombreProceso,
	Descripcion,
	idinstalacion,
	IsProcesoEvento,
	ISNULL(p.IsSerie,1) AS isSerie,
	isnull(clave,'') as Clave,
	P.CreadoEl,
	U.Nombre AS CreadoPor,
	p.EtapaPozoId
	FROM
		EN_Procesos p
	JOIN 
		en_procesosContrato PC 
		ON PC.idProceso= p.IdProceso
	JOIN 
		AP_Usuario U
		ON P.CreadoPor	=	U.UsuarioID
	WHERE 
		PC.idContrato=@idContrato 
		AND idTipoProceso=10000
		AND p.Activo=1;
END